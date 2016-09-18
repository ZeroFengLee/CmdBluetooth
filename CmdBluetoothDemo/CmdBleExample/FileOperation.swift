//
//  FileOperation.swift
//  CmdBleExample
//
//  Created by Zero on 16/8/17.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation

class FileOperation {
    
    var bufferSize: Int = 1024
    private var buffer: NSMutableData
    private var filePath: String
    let fileManager = NSFileManager.defaultManager()
    
    init() {
        buffer = NSMutableData()
        let docPath = NSHomeDirectory().stringByAppendingString("/Documents/ECG")
        if !fileManager.fileExistsAtPath(docPath, isDirectory: nil) {
            try! fileManager.createDirectoryAtPath(docPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fileName = dateFormatter.stringFromDate(NSDate()) + ".ecg"
        filePath = NSHomeDirectory().stringByAppendingString("/Documents/ECG/" + fileName)
    }
    
    func append(data: NSData) {
        if !fileManager.fileExistsAtPath(filePath) {
            fileManager.createFileAtPath(filePath, contents: nil, attributes: nil)
        }
        
        buffer.appendData(data)
        if buffer.length >= bufferSize {
            //写入文件
            let fileHandle = NSFileHandle(forWritingAtPath: filePath)
            fileHandle?.seekToEndOfFile()
            fileHandle?.writeData(buffer)
            //恢复buffer
            buffer = NSMutableData()
        }
    }
    
    class func removeFile(fileName: String) {
        let fileManager = NSFileManager.defaultManager()
        let filePath = NSHomeDirectory().stringByAppendingString("/Documents/ECG" + fileName)
        do {
            try fileManager.removeItemAtPath(filePath)
        } catch {
            print("删除文件失败")
        }
        
    }
}