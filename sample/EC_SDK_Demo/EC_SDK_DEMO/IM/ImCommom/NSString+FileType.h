//
//  NSString+FileType.h
//
//  Created on 9/11/15.
//  Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileType)

#define GROUP_FOLDER_BASE_RANG 0x10000
typedef NS_ENUM(NSInteger, ESpageGPFileStatus) {
    ESpaceGPFilePreuploaded = 1,
    ESpageGPFileUploading,
    ESpaceGPFileUploadFailed,
    ESpaceGPFileUploaded,
    ESpaceGPFileStatusNormal,
    ESpaceGPFileDownloading,
    ESpaceGPFileDownloadFailed,
    ESpageGPFileDownloaded
};

typedef NS_ENUM(NSUInteger, ESpaceGPFileType) {
    ESpaceGPUnknownFile = 0,
    
    //MS Office
    ESpaceGPWordFile,
    ESpaceGPExcelFile,
    ESpaceGPPPTFile,
    ESpaceGPPDFFile,
    ESpaceGPTxtFile,
    ESpaceGPCSVFile,
    ESpaceGPLogFile,
    ESpaceGPOfficeEnd = 20,
    //image file
    ESpaceGPJPEGFile,
    ESpaceGPJPGFile,
    ESpaceGPPNGFile,
    ESpaceGPBMPFile,
    ESpaceGPGIFFile,
    ESpaceGPTIFFFile,
    ESpaceGPRAWFile,
    ESpaceGPPPMFile,
    ESpaceGPPGMFile,
    ESpaceGPPBMFile,
    ESpaceGPPNMFile,
    ESpaceGPWEBPFile,
    ESpaceGPImageEnd = 40,
    //video file
    ESpaceGPAVIFile,
    ESpaceGPFLVFile,
    ESpaceGPRMVBFile,
    ESpaceGPMP4File,
    ESpaceGPMOVFile,
    ESpaceGPWMVFile,
    ESpaceGPVideoEnd = 60,
    //audio file
    ESpaceGPWAVFile,
    ESpaceGPWMAFile,
    ESpaceGPM4AFile,
    ESpaceGPMP3File,
    ESpaceGPAACFile,
    ESpaceGPAC3File,
    ESpaceGPAudioEnd = 80,
    //compress file
    ESpaceGPZIPFile,
    ESpaceGP7zFile,
    ESpaceGPRARFile,
    ESpaceGPGZIPFile,
    ESpaceGPTARFile,
    ESpaceGPCompressEnd = 100,
    // Code file
    ESpaceGPCodeFile,
    ESpaceGPHTMLFile,
    ESpaceGPXMLFile,
    ESpaceGPScriptFile,
    ESpaceGPStructFile,
    ESpaceGPCodeFileEnd = 120,
    
    // Config file
    ESpaceGPCFGFile,
    ESpaceGPCFGFileEnd = 140,
    
    // Database file
    ESpaceGPDBFile,
    ESpaceGPDBFileEnd = 160,
    
    // Other platform
    ESpaceGPDLLFile,
    ESpaceGPEXEFile,
    ESpaceGPEPSFile,
    ESpaceGPHelpFile,
    ESpaceGPAIFile,
    ESpaceGPISOFile,
    ESpaceGPPSFile,
    ESpaceGPSVGFile,
    ESpaceGPOtherPlatformEnd = 180,

    
    ESpaceGPFolderType = GROUP_FOLDER_BASE_RANG
};

- (ESpaceGPFileType) fileType;

@end
