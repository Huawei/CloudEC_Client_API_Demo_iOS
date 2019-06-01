//
//  NSString+FileType.m
//  eSpace
//
//  Created by zhangminliang on 9/11/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "NSString+FileType.h"

@implementation NSString (FileType)

- (ESpaceGPFileType) fileType {
    NSString* extension = [[self pathExtension] lowercaseString];
    CFStringRef fileExtension = (__bridge CFStringRef)extension;
    CFStringRef fileUTI= UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    ESpaceGPFileType fileType = 0;
    if ([extension isEqual:@""]) {
        fileType = ESpaceGPUnknownFile;
    } else if ([extension isEqual:@"doc"] || [extension isEqual:@"docx"] ) {
        fileType = ESpaceGPWordFile;
    } else if ([extension isEqual:@"xls"] || [extension isEqual:@"xlsx"]) {
        fileType = ESpaceGPExcelFile;
    } else if ([extension isEqual:@"ppt"] || [extension isEqual:@"pptx"]) {
        fileType = ESpaceGPPPTFile;
    } else if ([extension isEqual:@"pdf"]) {
        fileType = ESpaceGPPDFFile;
    } else if ([extension isEqual:@"jpeg"]) {
        fileType = ESpaceGPJPEGFile;
    } else if ([extension isEqual:@"jpg"]) {
        fileType = ESpaceGPJPGFile;
    } else if ([extension isEqual:@"png"]) {
        fileType = ESpaceGPPNGFile;
    } else if ([extension isEqual:@"bmp"]) {
        fileType = ESpaceGPBMPFile;
    } else if ([extension isEqual:@"gif"]) {
        fileType = ESpaceGPGIFFile;
    } else if ([extension isEqual:@"tiff"] || [extension isEqual:@"tif"]) {
        fileType = ESpaceGPTIFFFile;
    } else if ([extension isEqual:@"raw"]) {
        fileType = ESpaceGPRAWFile;
    } else if ([extension isEqual:@"ppm"]) {
        fileType = ESpaceGPPPMFile;
    } else if ([extension isEqual:@"pgm"]) {
        fileType = ESpaceGPPGMFile;
    } else if ([extension isEqual:@"pbm"]) {
        fileType = ESpaceGPPBMFile;
    } else if ([extension isEqual:@"pnm"]) {
        fileType = ESpaceGPPNMFile;
    } else if ([extension isEqual:@"webp"]) {
        fileType = ESpaceGPWEBPFile;
    } else if ([extension isEqual:@"avi"]) {
        fileType = ESpaceGPAVIFile;
    } else if ([extension isEqual:@"flv"]) {
        fileType = ESpaceGPFLVFile;
    } else if ([extension isEqual:@"rmvb"]) {
        fileType = ESpaceGPRMVBFile;
    } else if ([extension isEqual:@"mp4"]) {
        fileType = ESpaceGPMP4File;
    } else if ([extension isEqual:@"mov"]) {
        fileType = ESpaceGPMOVFile;
    } else if ([extension isEqual:@"wmv"]) {
        fileType = ESpaceGPWMVFile;
    } else if ([extension isEqual:@"zip"]) {
        fileType = ESpaceGPZIPFile;
    } else if ([extension isEqual:@"gzip"]) {
        fileType = ESpaceGPGIFFile;
    } else if ([extension isEqual:@"rar"]) {
        fileType = ESpaceGPRARFile;
    } else if ([extension isEqual:@"7z"]) {
        fileType = ESpaceGPRARFile;
    } else if ([extension isEqual:@"tar"]) {
        fileType = ESpaceGPTARFile;
    } else if ([extension isEqual:@"txt"]){
        fileType = ESpaceGPTxtFile;
    } else if ([extension isEqual:@"csv"]){
        fileType = ESpaceGPCSVFile;
    } else if ([extension isEqual:@"log"]){
        fileType = ESpaceGPLogFile;
    } else if([extension isEqual:@"mp3"]){
        fileType = ESpaceGPMP3File;
    } else if([extension isEqual:@"wma"]){
        fileType = ESpaceGPWMAFile;
    } else if([extension isEqual:@"wav"]){
        fileType = ESpaceGPWAVFile;
    } else if([extension isEqual:@"m4a"]){
        fileType = ESpaceGPM4AFile;
    } else if([extension isEqual:@"ac3"]){
        fileType = ESpaceGPM4AFile;
    } else if([extension isEqual:@"aac"]){
        fileType = ESpaceGPM4AFile;
    } else if ([extension isEqualToString:@"cfg"]) {
        fileType = ESpaceGPCFGFile;
    } else if ([extension isEqualToString:@"dll"]) {
        fileType = ESpaceGPDLLFile;
    } else if ([extension isEqualToString:@"exe"]) {
        fileType = ESpaceGPEXEFile;
    } else if ([extension isEqualToString:@"eps"]) {
        fileType = ESpaceGPEPSFile;
    } else if ([extension isEqualToString:@"help"]) {
        fileType = ESpaceGPHelpFile;
    } else if ([extension isEqualToString:@"ai"]) {
        fileType = ESpaceGPAIFile;
    } else if ([extension isEqualToString:@"iso"]) {
        fileType = ESpaceGPISOFile;
    } else if ([extension isEqualToString:@"psd"]) {
        fileType = ESpaceGPPSFile;
    } else if ([extension isEqualToString:@"svg"]) {
        fileType = ESpaceGPSVGFile;
    } else if ([extension isEqualToString:@"db"]) {
        fileType = ESpaceGPDBFile;
    } else if (UTTypeConformsTo(fileUTI, kUTTypeSourceCode)) {
        fileType = ESpaceGPCodeFile;
    } else if (UTTypeConformsTo(fileUTI, kUTTypeHTML)) {
        fileType = ESpaceGPHTMLFile;
    } else if (UTTypeConformsTo(fileUTI, kUTTypeXML)) {
        fileType = ESpaceGPXMLFile;
    } else if (UTTypeConformsTo(fileUTI, kUTTypeScript)) {
        fileType = ESpaceGPScriptFile;
    } else if (UTTypeConformsTo(fileUTI, kUTTypeXMLPropertyList)) {
        fileType = ESpaceGPStructFile;
    } else {
        fileType = ESpaceGPUnknownFile;
    }
    CFRelease(fileUTI);
    return fileType;
}

@end
