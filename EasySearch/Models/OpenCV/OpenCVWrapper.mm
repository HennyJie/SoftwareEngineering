//
//  OpenCVWrapper.m
//  OpenCvTest
//
//  Created by l_yq on 2017/11/27.
//  Copyright © 2017年 linyiqun. All rights reserved.
//

#import <opencv2/stitching/detail/blenders.hpp>
#import <opencv2/stitching/detail/exposure_compensate.hpp>

#import "OpenCVWrapper.h"


#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

#import <opencv2/features2d.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/xfeatures2d.hpp>

#import <math.h>


@implementation OpenCVWrapper

const double kernRatio = 0.01; //自适应核比例
const double minAtomLigth = 220; //最小大气光强
const double wFactor = 0.95; //w系数 用来调节
const double min_t = 0.1; //最小透射率
cv::Mat m_srcImage; //原始图像
cv::Mat m_tImage;  //透射率
cv::Mat m_dstImage; //结果图像

// =======================================================
// C++ functions
bool matIsEqual(const cv::Mat mat1, const cv::Mat mat2) {
    if (mat1.empty() && mat2.empty()) {
        return true;
    }
    if (mat1.cols != mat2.cols || mat1.rows != mat2.rows || mat1.dims != mat2.dims||
        mat1.channels()!=mat2.channels()) {
        return false;
    }
    if (mat1.size() != mat2.size() || mat1.channels() != mat2.channels() || mat1.type() != mat2.type()) {
        return false;
    }
    int nrOfElements1 = (int) mat1.total() * (int) mat1.elemSize();
    if (nrOfElements1 != mat2.total() * mat2.elemSize()) return false;
    bool lvRet = memcmp(mat1.data, mat2.data, nrOfElements1) == 0;
    return lvRet;
}

std::vector<cv::KeyPoint> getKeyPointsFromImage(UIImage *image) {
    // the input image must be a rgb image (with 3 channels)
    std::vector<cv::KeyPoint> keypoint;
    
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
    
    // note: input image MUST BE A GRAY SCALE image, or you will get a wrong set of keypoints
    cv::FAST(grayMat, keypoint, 15);
    
    return keypoint;
}

cv::Mat convertFloatArrayToCVMat(float **parray, int row, int col) {
    cv::Mat res = cv::Mat::zeros(row, col, 5);// CV_32F
    for(int i = 0; i < col; i++) {
        for(int j = 0; j < row; j++) {
            res.at<float>(i, j) = parray[i][j];
        }
    }
    
    return res;
}

float ** convertCVMatToFloatArray(cv::Mat& mat) {
    float **res;
    res = new float*[mat.cols];
    
    for(int i = 0; i < mat.cols ; i++) {
        res[i] = new float[mat.rows];
        for(int j = 0; j < mat.rows; j++) {
            res[i][j] = mat.at<float>(i, j);
        }
    }
    
    return res;
}

NSArray* convertCVMatToNSArray(cv::Mat& mat) {
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:0];
    std::cout<< "mat type: " << mat.type() <<std::endl;
    
    for(int i = 0; i < mat.cols; i++) {
        for(int j = 0; j < mat.rows; j++) {
            [array addObject:[NSNumber numberWithFloat: mat.at<float>(i, j)]];
        }
    }
    
    return array;
}

cv::Mat convertNSArrayToCVMat(NSArray* array, int row, int col) {
    cv::Mat res = cv::Mat::zeros(row, col, 5);// CV_32F
    
    for(int i = 0; i < col; i++) {
        for(int j = 0; j < row; j++) {
            float tmp = (float)[[array objectAtIndex:(i*row+j)] floatValue];
            res.at<float>(i, j) = tmp;
            
        }
    }
    
    return res;
}

cv::Mat minRGB(cv::Mat src)
{
    cv::Mat minRgb;
    if (src.empty())
        return minRgb;
    
    minRgb = cv::Mat::zeros(src.rows, src.cols, CV_8UC1);
    for (int i = 0;i<src.rows;i++)
        for (int j = 0;j<src.cols;j++)
        {
            uchar g_minvalue = 255;
            for (int c = 0;c<3;c++)
            {
                if (g_minvalue>src.at<cv::Vec3b>(i, j)[c])
                    g_minvalue = src.at<cv::Vec3b>(i, j)[c];
            }
            minRgb.at<uchar>(i, j) = g_minvalue;
        }
    return minRgb;
}

//最小值滤波
cv::Mat minFilter(cv::Mat src, int ksize)
{
    cv::Mat dst;
    //[1] --检测原始图像
    if (src.channels() != 1)
        return dst;  //返回空矩阵
    if (src.depth()>8)
        return dst;
    //[1]
    
    int r = (ksize - 1) / 2; //核半径
    
    //初始化目标图像
    dst = cv::Mat::zeros(src.rows, src.cols, CV_8UC1);
    
    //[3] --最小值滤波
    for (int i = 0;i<src.rows;i++)
        for (int j = 0;j<src.cols;j++)
        {
            
            //[1] --初始化滤波核的上下左右边界
            int top = i - r;
            int bottom = i + r;
            int left = j - r;
            int right = j + r;
            //[1]
            
            //[2] --检查滤波核是否超出边界
            if (i - r<0)
                top = 0;
            if (i + r>src.rows)
                bottom = src.rows;
            if (j - r<0)
                left = 0;
            if (j + r>src.cols)
                right = src.cols;
            //[2]
            
            //[3] --求取模板下的最小值
            cv::Mat ImROI = src(cv::Range(top, bottom), cv::Range(left, right));
            double min, max;
            minMaxLoc(ImROI, &min, &max, 0, 0);
            dst.at<uchar>(i, j) = min;
            //[3]
        }
    //[3]
    return dst;
}

//导向滤波
cv::Mat guildFilter(cv::Mat g, cv::Mat p, int ksize)
{
    const double eps = 1.0e-5;//regularization parameter
    //类型转换
    cv::Mat _g;
    g.convertTo(_g, CV_64FC1);
    g = _g;
    
    cv::Mat _p;
    p.convertTo(_p, CV_64FC1);
    p = _p;
    
    //[hei, wid] = size(I);
    int hei = g.rows;
    int wid = g.cols;
    
    //N = boxfilter(ones(hei, wid), r); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.
    cv::Mat N;
    cv::boxFilter(cv::Mat::ones(hei, wid, g.type()), N, CV_64FC1, cv::Size(ksize, ksize));
    
    //[1] --使用均值模糊求取各项系数
    cv::Mat mean_G;
    boxFilter(g, mean_G, CV_64FC1, cv::Size(ksize, ksize));
    
    cv::Mat mean_P;
    boxFilter(p, mean_P, CV_64FC1, cv::Size(ksize, ksize));
    
    cv::Mat GP = g.mul(p);
    cv::Mat mean_GP;
    boxFilter(GP, mean_GP, CV_64FC1, cv::Size(ksize, ksize));
    
    cv::Mat GG = g.mul(g);
    cv::Mat mean_GG;
    boxFilter(GG, mean_GG, CV_64FC1, cv::Size(ksize, ksize));
    
    cv::Mat cov_GP;
    cov_GP = mean_GP - mean_G.mul(mean_P);
    
    cv::Mat var_G;
    var_G = mean_GG - mean_G.mul(mean_G);
    //[1]
    
    //求系数a a=(mean(GP)-mean(G)mean(p))/(mean(GG)-mean(G)mean(G)+eps)
    cv::Mat a = cov_GP / (var_G + eps);
    
    //求系数b b=mean(P)-mean(G)*a
    cv::Mat b = mean_P - a.mul(mean_G);
    
    //求两个系数的均值
    cv::Mat mean_a;
    boxFilter(a, mean_a, CV_64FC1, cv::Size(ksize, ksize));
    //mean_a=mean_a/N;
    
    cv::Mat mean_b;
    boxFilter(b, mean_b, CV_64FC1, cv::Size(ksize, ksize));
    //mean_b=mean_b/N;
    
    //输出结果q
    cv::Mat q = mean_a.mul(g) + mean_b;
    // qDebug()<<q.at<double>(100,100);
    
    return q;
}


//图像灰度拉伸
//src 灰度图图
//lowcut、highcut为百分比的值 如lowcut=3表示3%
//lowcut表示暗色像素的最小比例，小于该比例均为黑色
//highcut为高亮像素的最小比例，大于该比例的均为白色
cv::Mat grayStretch(const cv::Mat src, double lowcut, double highcut)
{
    //[1]--统计各通道的直方图
    //参数
    const int bins = 256;
    int hist_size = bins;
    float range[] = { 0,255 };
    const float* ranges[] = { range };
    cv::MatND desHist;
    int channels = 0;
    //计算直方图
    calcHist(&src, 1, &channels, cv::Mat(), desHist, 1, &hist_size, ranges, true, false);
    //[1]
    
    //[2] --计算上下阈值
    int pixelAmount = src.rows*src.cols; //像素总数
    float Sum = 0;
    int minValue = 0, maxValue = 0;
    //求最小值
    for (int i = 0;i<bins;i++)
    {
        Sum = Sum + desHist.at<float>(i);
        if (Sum >= pixelAmount*lowcut*0.01)
        {
            minValue = i;
            break;
        }
    }
    
    //求最大值
    Sum = 0;
    for (int i = bins - 1;i >= 0;i--)
    {
        Sum = Sum + desHist.at<float>(i);
        if (Sum >= pixelAmount*highcut*0.01)
        {
            maxValue = i;
            break;
        }
    }
    //[2]
    
    //[3] --对各个通道进行线性拉伸
    cv::Mat dst = src;
    //判定是否需要拉伸
    if (minValue>maxValue)
        return src;
    
    for (int i = 0;i<src.rows;i++)
        for (int j = 0;j<src.cols;j++)
        {
            if (src.at<uchar>(i, j)<minValue)
                dst.at<uchar>(i, j) = 0;
            if (src.at<uchar>(i, j)>maxValue)
                dst.at<uchar>(i, j) = 255;
            else
            {
                //注意这里做除法要使用double类型
                double pixelValue = ((src.at<uchar>(i, j) - minValue) /
                                     (double)(maxValue - minValue)) * 255;
                dst.at<uchar>(i, j) = (int)pixelValue;
            }
        }
    //[3]
    
    return dst;
}

//暗原色原理去雾
cv::Mat darkChannelDefog(cv::Mat src)
{
    
    if(src.channels() == 4) {
        cv::cvtColor(src, src, CV_RGBA2RGB);
    }
    
    //[1] --minRGB
    cv::Mat tempImage = minRGB(src);
    //[1]
    
    //[2] --minFilter
    int ksize = std::max(3, std::max((int)(src.cols*kernRatio),
                                (int)(src.rows*kernRatio))); //求取自适应核大小
    tempImage = minFilter(tempImage, ksize);
    //[2]
    
    //[3] --dark channel image
    m_tImage = cv::Mat::zeros(src.rows, src.cols, CV_64FC1);
    for (int i = 0;i<src.rows;i++)
        for (int j = 0;j<src.cols;j++)
            m_tImage.at<double>(i, j) = ((255.0 -
                                          (double)tempImage.at<uchar>(i, j)*wFactor) / 255) - 0.005;
    
    //[3]
    
    //[4] --求取全球大气光强A(全局量)
    double A[3];
    cv::Point maxLoc;
    minMaxLoc(tempImage, 0, 0, 0, &maxLoc);
    for (int c = 0;c<src.channels();c++)
        A[c] = src.at<cv::Vec3b>(maxLoc.y, maxLoc.x)[c];
    //[4]
    
    //[5] --根据去雾公式求取去雾图像  J=(I-(1-t)*A)/max(t,min_t)
    m_dstImage = cv::Mat::zeros(src.rows, src.cols, CV_64FC3);
    for (int i = 0;i<src.rows;i++)
        for (int j = 0;j<src.cols;j++)
            for (int c = 0;c<src.channels();c++)
                m_dstImage.at<cv::Vec3d>(i, j)[c] = (src.at<cv::Vec3b>(i, j)[c] -
                                                 (1 - m_tImage.at<double>(i, j))*A[c]) /
                std::max(m_tImage.at<double>(i, j), min_t);
    m_dstImage.convertTo(m_dstImage, CV_8UC3);
    //[5]
    
    return m_dstImage;
    
}

cv::Mat enhanceImage(cv::Mat src)
{
    cv::Mat dst;
    //[6] --自动色阶（rgb三通道灰度拉伸）
    cv::Mat channels[3];
    split(src, channels);//不知道什么原因vector无法使用 只能用数组来表示
    for (int c = 0;c<3;c++)
        channels[c] = grayStretch(channels[c], 0.001, 1); //根据实验 暗色像素的比例应该设置的较小效果会比较好
    merge(channels, 3, dst);
    
    return dst;
}

//返回透射图
cv::Mat getTImage()
{
    cv::Mat temp = cv::Mat::zeros(m_tImage.rows, m_tImage.cols, CV_8UC1);
    for (int i = 0;i<m_tImage.rows;i++)
        for (int j = 0;j<m_tImage.cols;j++)
        {
            temp.at<uchar>(i, j) = (int)(m_tImage.at<double>(i, j) * 255);
        }
    m_tImage.convertTo(m_tImage, CV_8UC1);
    m_tImage = temp;
    return m_tImage;
}

// =======================================================



// =======================================================
// interface

// return opencv version
+(NSString *) openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

// return a gray scale image of the input
+(UIImage *) makeGrayFromImage:(UIImage *)image {
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
//    std::cout << imageMat.size << std::endl;
    
    if(imageMat.channels() == 1) return image;
    
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
    
//    std::cout << grayMat.size << std::endl;
    
    return MatToUIImage(grayMat);
}

// return a image tailered from a set of images
+(UIImage *) tailerImage:(NSArray<UIImage *> *)imageArray {
    cv::Mat tailerResult;
    UIImageToMat(imageArray[0], tailerResult);
    
    for(int i = 1; i < imageArray.count; i++) {
        cv::Mat imageMat;
        UIImageToMat(imageArray[i], imageMat);
        
        // get the last row
        cv::Mat endMat = tailerResult.rowRange(tailerResult.rows-20, tailerResult.rows);
        
        for(int j = 21; j < imageMat.rows; j++) {
            // 相同的一行
            if(matIsEqual(imageMat.rowRange(j-20, j), endMat)) {
                tailerResult.push_back(imageMat.rowRange(j, imageMat.rows));
                break;
            }
        }
    }
    
    return MatToUIImage(tailerResult);
}

// return the list of keypoint of a image
// TODO: need to test
+(NSArray<UnbelievableKeyPoint *> *) getKeyPointsFrom:(UIImage *)image {
    NSMutableArray<UnbelievableKeyPoint *> *resultKeyPoint = [[NSMutableArray<UnbelievableKeyPoint *> alloc] init];
    
    // the input image must be a rgb image (with 3 channels)
    std::vector<cv::KeyPoint> keypoint = getKeyPointsFromImage(image);
    
    for(int i = 0; i < keypoint.size(); i++) {
        UnbelievableKeyPoint *ukp = [[UnbelievableKeyPoint alloc] init];
        ukp.x = keypoint[0].pt.x;
        ukp.y = keypoint[0].pt.y;
        ukp.size = keypoint[0].size;
        ukp.angle = keypoint[0].angle;
        ukp.response = keypoint[0].response;
        ukp.octave = keypoint[0].octave;
        ukp.class_id = keypoint[0].class_id;
        [resultKeyPoint addObject: ukp];
    }
    
    return resultKeyPoint;
}

+(UnbelievableDescriptor *) getDescriptorsFromImage:(UIImage *)image {
    
    UnbelievableDescriptor *des = [[UnbelievableDescriptor alloc] init];
    
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    cv::Mat grayMat = imageMat;
    if(imageMat.channels() != 1)
        cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
    
    std::vector<cv::KeyPoint> kp;
    cv::Mat mask = cv::Mat::ones(imageMat.size(), CV_8U);
    cv::Mat desp;
    
    cv::xfeatures2d::SIFT::create()->detectAndCompute(grayMat, mask, kp, desp);
    
    des.row = desp.rows;
    des.col = desp.cols;
    
//    des.des = convertCVMatToFloatArray(desp);++++++
    des.des = convertCVMatToNSArray(desp);
    // visit: ded[col...][row...]
    
    return des;
}

+(cv::Mat) getDesMatFromImage:(UIImage *)image {
    
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    cv::Mat grayMat = imageMat;
    if(imageMat.channels() != 1)
        cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
    
    std::vector<cv::KeyPoint> kp;
    cv::Mat mask = cv::Mat::ones(imageMat.size(), CV_8U);
    cv::Mat desp;
    
    cv::xfeatures2d::SIFT::create()->detectAndCompute(grayMat, mask, kp, desp);
    
    return desp;
}

+(int) getMatchedPairsFromDesciptor:(UnbelievableDescriptor *)desp toMatch:(UnbelievableDescriptor *)mDesp {
    int res = 0;
    
    // convert to cv mat
    cv::Mat mat_desp  = convertNSArrayToCVMat(desp.des,  desp.row,  desp.col);
    cv::Mat mat_mdesp = convertNSArrayToCVMat(mDesp.des, mDesp.row, mDesp.col);
    
    std::vector<std::vector<cv::DMatch> > matches;
    cv::BFMatcher().knnMatch(mat_desp, mat_mdesp, matches, 2);
    
    for(int i = 0; i < matches.size(); i++ ) {
        float m = matches[i][0].distance;
        float n = matches[i][1].distance;
        
        if(m < 0.9*n) {
            res++;
        }
    }
    
    return res;
}

+(int) getMatchedPairsFromImage:(UIImage *)image1 toMatchImage:(UIImage *) image2 {
    int res = 0;
    
    cv::Mat mat_desp = [self getDesMatFromImage:image1];
    cv::Mat mat_mdesp = [self getDesMatFromImage:image2];
    
    std::vector<std::vector<cv::DMatch> > matches;
    cv::BFMatcher().knnMatch(mat_desp, mat_mdesp, matches, 2);
    
    for(int i = 0; i < matches.size(); i++ ) {
        float m = matches[i][0].distance;
        float n = matches[i][1].distance;
        
        if(m < 0.9*n) {
            res++;
        }
    }
    
    return res;
}

+(int) getMatchedPairsFromImage:(UIImage *)image toMatchDescriptor:(UnbelievableDescriptor *)mDesp {
    int res = 0;
    
    UnbelievableDescriptor *desp = [self getDescriptorsFromImage:image];
    res = [self getMatchedPairsFromDesciptor:desp toMatch:mDesp];
    
    return res;
}

+(UIImage *) resizeImage:(UIImage *)image toSize:(int) row andCol:(int)col {
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    std::cout<< "resize Image: image's channel: "<< mat.channels()<< std::endl;
    
//    if(mat.channels() == 4) {
//        cv::cvtColor(mat, mat, CV_RGBA2RGB);
//    }
    
    cv::Size size;
    size.width = row;
    size.height = col;
    
    cv::Mat res;
    cv::resize(mat, res, size);
    
    cv::Mat grayMat;
    // TODO: not return a gray image.
    // here, we return a gray image, because the image resized is used to do some processing. so...
    // also, todo: do something when the image's color field is RGBA(channels = 4 => RGB (3) )
    if(res.channels() == 1) {
        return MatToUIImage(res);
    }
    cv::cvtColor(res, grayMat, CV_BGR2GRAY);
    
    return MatToUIImage(grayMat);
}

+(UIImage *) lightingImage:(UIImage *)image {
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    if(mat.channels() == 4) {
        std::cout<< "lighting image: a rgba image, convert to rgb"<< std::endl;
        cv::cvtColor(mat, mat, CV_RGBA2RGB);
    }
    
    cv::Mat imageRGB[3];
    cv::split(mat, imageRGB);
    for(int i = 0; i < 3; i++) {
        cv::equalizeHist(imageRGB[i], imageRGB[i]);
    }
    cv::merge(imageRGB, 3, mat);
    return MatToUIImage(mat);
}

+(long long) encodeImage:(UIImage *)image {
    cv::Mat grayMat;
    UIImageToMat([self resizeImage:image toSize:8 andCol:8], grayMat);
    
   long long res = 0;
    
    bool *vres = new bool[64];
    int cnt = 0;
    
    for(int i = 0; i < 8; i++) {
        for(int j = 0; j < 8; j++) {
            char val = grayMat.at<char>(i, j);
            
            int i_val = (int)val + 128;
            int64 p_val = i_val > 127 ? 1 : 0;
            vres[cnt] = i_val > 127;
            
            res += (p_val << cnt);
//            std::cout<< vres[cnt] << " ";
            cnt++;
        }
//        std::cout<< std::endl;
    }
//    std::cout<< "code: ";
//    std::cout<< res << std::endl;
//    std::cout<< std::endl;
    
    return res;
}

+(bool) compareImageCode:(bool *)code1 with:(bool *)code2 {
    for(int i = 0; i < 64; i++) {
        if(code1[i] != code2[i])
            return false;
    }
    return true;
}

+(bool) compareImage:(UIImage *)image with:(UIImage *)image2 {
    cv::Mat mat1;
    cv::Mat mat2;
    
    UIImageToMat(image, mat1);
    UIImageToMat(image2, mat2);
    
    return matIsEqual(mat1, mat2);
}

+(UIImage *) adaptiveThreshold:(UIImage *)image {
    cv::Mat input;
    cv::Mat output;
    UIImageToMat(image, input);
    
    cv::Mat grayMat;
    cv::cvtColor(input, grayMat, CV_BGR2GRAY);
    
    cv::adaptiveThreshold(grayMat, output, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 51, 1);
    
    return MatToUIImage(output);
}

+(UIImage *) defog:(UIImage *)image {
    cv::Mat srcImage;
    UIImageToMat(image, srcImage);
    
    cv::Mat imagedeFog = darkChannelDefog(srcImage);
    
    cv::Mat stretch = enhanceImage(imagedeFog);
    
    return MatToUIImage(stretch);
}

+(UIImage *) bitwiseNot:(UIImage *)image {
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::Mat res;
    
    cv::bitwise_not(mat, res);
    
    return MatToUIImage(res);
}

// just only a test function
+(UIImage *) justATest:(UIImage *)image {
    
    
    cv::Mat res;
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int i = 0 ; i < 128 * 1000; i++) {
        [array addObject: [[NSNumber alloc]initWithFloat: 10]];
    }
    
    for(int i = 0 ; i < 128 * 1000; i++) {
//        NSNumber *key = [[NSNumber alloc] initWithInt:i];
        [array objectAtIndex:i];
    }
 
    return MatToUIImage(res);
}


@end
