//
//  Parsing.swift
//  AHPP
//
//  Created by Ben Neely on 3/15/15.
//  Copyright (c) 2015 boisestate. All rights reserved.
//

import Foundation
import AHPP

public class ParsingTest{
    
    
    public class func parseTester(filename: String) -> LookupTableGeneratorTester
    {

        let absolute = "/Users/rovery/CompSci/AHHP/AHPP-iOS-App/AHPP/AHPPTests/"
        
        return LookupTableGeneratorTester(path: absolute+filename)
    }
    
    
    
    private class func saveDataCells(table: Array2D, lookUpTable: LookUpTable, isHige: Bool, isHoge: Bool)
    {
        if(table.colCount()>0 && table.rowCount()>0)
        {
            for col in 1..<table.colCount()
            {
                for row in 1..<table.rowCount()
                {
                    if(table[col,row] != nil && table[col,row]>=0)
                    {
                        ViewController.saveDataCell(
                            table[0,row-1]!,
                            temperature: table[col, 0]!,
                            weight: table[col,row]!,
                            lookUpTable: lookUpTable,
                            isHige: isHige,
                            isHoge: isHoge)
                    }
                }
            }
        }
    }
}


public class LookupTableGeneratorTester
{
    var company_name: String = ""
    var contact_number: String = ""
    var designated_base: String = ""
    var fixed_weight_reduduction: NSNumber = 0
    var flight_crew_weight: NSNumber = 0
    var gross_weight_limitation_hige: NSNumber = 0
    var gross_weight_limitation_hoge: NSNumber = 0
    var gross_weight_limitation_hoge_j: NSNumber = 0
    var helicopter_equipped_weight: NSNumber = 0
    var is_hoge: NSNumber = 0
    var make_model: String = ""
    var n_number: String = ""
    var performance_reference_hige: String = ""
    var performance_reference_hoge: String = ""
    var pilot_name: String = ""
    var has_wat: Bool = false
    
    var table_num: Int = 0
    var path: String
    var atTable: Bool = false
    var aStreamReader: StreamReader
    //
    init(path: String)
    {
        self.path = path
        self.aStreamReader = StreamReader(path: self.path)!
    }
    
    
    public func getMetaData() -> [AnyObject]
    {
        var processing: Bool = true
        var strings: [String]
        var array: [AnyObject] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        
        strings = getMetaStrings()
        for var i = 0; i<strings.count; i++
        {
            var temp = strings[i]
            switch temp
            {
            case "Designated Base":
                array[2] = strings[i+1]
                i++
            case "Contract #":
                array[1] = strings[i+1]
                i++
            case "Company Name":
                array[0] = strings[i+1]
                i++
            case "Fixed Weight Reduction":
                array[3] = strings[i+1].toInt()!
                i++
            case "Make/Model":
                array[10] = strings[i+1]
                i++
            case "Performance Reference HIGE":
                array[12] = strings[i+1]
                i++
            case "N#":
                array[11] = strings[i+1]
                i++
            case "Gross Weight Limitation HIGE":
                array[5] = strings[i+1].toInt()!
                i++
            case "Helicopter Equipped Weight":
                array[8] = strings[i+1].toInt()!
                i++
            case "Performance Reference HOGE":
                array[13] = strings[i+1]
                i++
            case "Pilot Name":
                array[14] = strings[i+1]
                i++
            case "Gross Weight Limitation HOGE":
                array[6] = strings[i+1].toInt()!
                i++
            case "Flight Crew Weight":
                array[4] = strings[i+1].toInt()!
                i++
            case "Gross Weight Limitation HOGE-J":
                array[7] = strings[i+1].toInt()!
                i++
            default:
                println()
            }
            array[9] = 0
            array[15] = false
        }
        return array
    }
    
    public func getDataCells() -> [NSNumber]
    {
        
        var cells: [NSNumber] = []
        var table: Array2D
        table = nextTable()
        if(table.colCount()>0 && table.rowCount()>0)
        {
            for var col=1; col<table.colCount(); col++
            {
                for var row = 1; row<table.rowCount(); row++
                {
                    if(table[col,row] != nil && table[col,row]>=0)
                    {
                        cells.append(table[0,row-1]!)
                        cells.append(table[col, 0]!)
                        cells.append(table[col,row]!)
                        
                    }
                }
            }
        }
        
        return cells
    }
    
    public func getArray2DDataCells() -> Array2D
    {
        return nextTable()
    }
    
    func nextTable() -> Array2D
    {
        var line: String
        var table: Array2D = Array2D(cols: 0, rows: 0)
        var dim: [Int]
        if(findTable())
        {
            self.table_num++
            dim = getTableDimensions()
            table = Array2D(cols: dim[0], rows: dim[1])
            for i in 0..<table.colCount()
            {
                let parsedline = getNextLine()
                for (j, cell) in enumerate(parsedline)
                {
                    table[i,j] = cell
                }
            }
            self.atTable = false
        }
        
        return table
    }
    
    func hasWatTable() -> Bool
    {
        var has_wat = false
        var i = 0;
        while(findTable())
        {
            i++
        }
        if i == 3
        {
            has_wat = true
        }
        self.aStreamReader.rewind()
        return has_wat
    }
    
    
    private func findTable() -> Bool
    {
        var table_found = false
        while let line = aStreamReader.nextLine()
        {
            if line.rangeOfString("Lookup Table") != nil
            {
                table_found = true
            }
            if(table_found)
            {
                self.atTable = true
                break
            }
        }
        return table_found
    }
    
    private func getTableDimensions() ->[Int]
    {
        var processing: Bool = true
        var colsrows: [Int] = [0,0]
        if(!self.atTable){findTable()}
        while(processing)
        {
            let parsedLine = getNextLine()
            if(!parsedLine.isEmpty)
            {
                if(parsedLine[0]<(0))
                {
                    processing = false
                } else {
                    colsrows[0]++
                }
                if(colsrows[1] < parsedLine.count)
                {
                    colsrows[1]=parsedLine.count
                }
            } else {
                processing = false;
            }
        }
        
        //return back to beginning of the table you were at
        aStreamReader.rewind()
        for i in 0..<self.table_num
        {
            findTable()
        }
        return colsrows
    }
    
    private func getMetaStrings() -> [String]
    {
        var processing: Bool = true
        var line: String
        var cells: [String] = Array<String>()
        while(processing)
        {
            line = aStreamReader.nextLine()!
            for cell in line.componentsSeparatedByString(",")
            {
                if (!cell.isEmpty)
                {
                    cells.append(cell)
                }
            }
            if line.rangeOfString("Flight Crew Weight") != nil
            {//found last line of meta data stop consuming more
                processing = false
            }
        }
        aStreamReader.rewind()
        return cells
        
    }
    
    private func getNextLine() -> [Int]
    {
        var line: String
        var cells: [String] = Array<String>()
        var parsed_cells: [Int] = Array<Int>()
        var atEnd: Bool = false
        var processing = true
        
        while(processing)
        {
            line = (aStreamReader.nextLine()!).stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            //split line up and remove empty elements
            for cell in line.componentsSeparatedByString(",")
            {
                if (!cell.isEmpty)
                {
                    cells.append(cell)
                }
            }
            let x = line.componentsSeparatedByString(",").count
            
            //if all cells is empty we have reached the end of our table
            if(cells.isEmpty)
            {
                atEnd = true
            } else {
                
                for cell in cells
                {
                    if((cell.toInt()) != nil)
                    {
                        parsed_cells.append(cell.toInt()!)
                    }
                }
            }
            
            /*
            * if parsed_cells is empty but were not at the end of the table.
            * This would happend because the row and col titles take up their
            * own line with no Integer elements on the line, causing a false empty
            */
            if(parsed_cells.isEmpty && atEnd)
            {
                parsed_cells.append(-1)
                processing = false
            } else if(!parsed_cells.isEmpty) {
                processing = false
            }
        }
        return parsed_cells
    }
}


public class Array2D {
    var cols:Int, rows:Int
    var matrix: [Int?]
    
    
    init(cols:Int, rows:Int) {
        self.cols = cols
        self.rows = rows
        matrix = Array(count:cols*rows, repeatedValue:nil)
    }
    
    subscript(col:Int, row:Int) -> Int? {
        get {
            return matrix[cols * row + col]
        }
        set {
            matrix[cols*row+col] = newValue
        }
    }
    
    func colCount() -> Int {
        return self.cols
    }
    
    func rowCount() -> Int {
        return self.rows
    }
}

class StreamReader  {
    
    let encoding : UInt
    let chunkSize : Int
    
    var fileHandle : NSFileHandle!
    var buffer : NSMutableData!
    var delimData : NSData!
    var atEof : Bool = false
    
    init?(path: String, delimiter: String = "\n", encoding : UInt = NSUTF8StringEncoding, chunkSize : Int = 4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding
        self.buffer = nil
        self.delimData = nil
        
        if let fileHandle = NSFileHandle(forReadingAtPath: path) {
            self.fileHandle = fileHandle
        } else {
            return nil
        }
        // Create NSData object containing the line delimiter:
        if let delimData = delimiter.dataUsingEncoding(NSUTF8StringEncoding) {
            self.delimData = delimData
        } else {
            return nil
        }
        if let buffer = NSMutableData(capacity: chunkSize) {
            self.buffer = buffer
        } else {
            return nil
        }
    }
    
    deinit {
        self.close()
    }
    
    /// Return next line, or nil on EOF.
    func nextLine() -> String? {
        
        if atEof {
            return nil
        }
        
        // Read data chunks from file until a line delimiter is found:
        var range = buffer.rangeOfData(delimData, options: nil, range: NSMakeRange(0, buffer.length))
        while range.location == NSNotFound {
            var tmpData = fileHandle.readDataOfLength(chunkSize)
            if tmpData.length == 0 {
                // EOF or read error.
                atEof = true
                if buffer.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = NSString(data: buffer, encoding: encoding);
                    buffer.length = 0
                    return (line as! String)
                }
                // No more lines.
                return nil
            }
            buffer.appendData(tmpData)
            range = buffer.rangeOfData(delimData, options: nil, range: NSMakeRange(0, buffer.length))
        }
        
        // Convert complete line (excluding the delimiter) to a string:
        let line = NSString(data: buffer.subdataWithRange(NSMakeRange(0, range.location)),
            encoding: encoding)
        // Remove line (and the delimiter) from the buffer:
        buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
        
        return (line as! String)
    }
    
    /// Start reading from the beginning of file.
    func rewind() -> Void {
        fileHandle.seekToFileOffset(0)
        buffer.length = 0
        atEof = false
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {
        if fileHandle != nil {
            fileHandle.closeFile()
            fileHandle = nil
        }
    }
}


