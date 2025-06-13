package kr.co.genesiskorea.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import com.sap.conn.jco.JCoFieldIterator;
import com.sap.conn.jco.JCoFunction;
import com.sap.conn.jco.JCoParameterList;
import com.sap.conn.jco.JCoStructure;
import com.sap.conn.jco.JCoTable;


public class RfcDataHandler {
	private static Logger logger = LogManager.getLogger(RfcDataHandler.class);
	/**
     * RFC Export Table에서 data 추출하기
     * 
     * @param function
     * @param tableName
     * @return
     */
    public static Map<String, Object> getExportData(JCoFunction function, List<String> exportParamNames) {
        
        JCoParameterList params = function.getExportParameterList();
        
        Map<String, Object> data = new HashMap<String, Object>();
        if (params != null && exportParamNames != null && exportParamNames.size() > 0) {
            for (String name : exportParamNames) {
                data.put(name, params.getValue(name));
            }
            if (logger.isDebugEnabled()) {
            	logger.debug("#### RFC Export Param Data >>> {}", data);
            }
        }

        return data;
    }
    
    /**
     * RFC Export Table에서 data 추출하기
     * 
     * @param function
     * @param tableName
     * @return
     */
    public static List<Map<String, Object>> getTableData(JCoFunction function, String tableName) {
        
        JCoTable table = function.getTableParameterList().getTable(tableName);
        if (logger.isDebugEnabled()) {
        	logger.debug("#### RFC Export Table({}) MetaData >>> {}", tableName, table.getMetaData());
        	logger.debug("#### RFC Export Table({}) NumRows  >>> {}", tableName, table.getNumRows());
        }
        
        List<Map<String, Object>> tableData = new ArrayList<Map<String, Object>>();
        if (table != null && !table.isEmpty()) {
            List<String> fieldNames = new ArrayList<String>();
            
            JCoFieldIterator fieldIter = table.getFieldIterator();
            while (fieldIter.hasNextField()) {
                fieldNames.add(fieldIter.nextField().getName());
            }
            if (logger.isDebugEnabled()) {
            	logger.debug("#### RFC Export Table({}) FieldNames >>> {}", tableName, fieldNames);
            }
            
            for (int i = 0; i < table.getNumRows(); i++) {
                table.setRow(i);
                
                Map<String, Object> recordData = new HashMap<String, Object>();
                for (String fieldName : fieldNames) {
                    recordData.put(fieldName, table.getValue(fieldName));
                }
                
                tableData.add(recordData);
            }
            if (logger.isDebugEnabled()) {
            	logger.debug("#### RFC Export Table({}) TableData >>> {}", tableName, tableData);
            }
        }
        
        return tableData;
    }
    
    /**
     * RFC Export Structure에서 data 추출하기
     * 
     * @param function
     * @param structureName
     * @return
     */
    public static Map<String, Object> getStructureData(JCoFunction function, String structureName, Map<String, String> fieldNameMap) {
        
        JCoStructure structure = function.getExportParameterList().getStructure(structureName);
        if (logger.isDebugEnabled()) {
        	logger.debug("#### RFC Export Structure({}) MetaData >>> {}", structureName, structure.getMetaData());
        	logger.debug("#### RFC Export Structure({}) FieldCount  >>> {}", structureName, structure.getFieldCount());
        }
        
        Map<String, Object> data = new HashMap<String, Object>();
        if (structure != null){
            List<String> fieldNames = new ArrayList<String>();
            
            JCoFieldIterator fieldIter = structure.getFieldIterator();
            while (fieldIter.hasNextField()) {
                fieldNames.add(fieldIter.nextField().getName());
            }
            if (logger.isDebugEnabled()) {
            	logger.debug("#### RFC Export Structure({}) FieldNames >>> {}", structureName, fieldNames);
            }

            for (String fieldName : fieldNames) {
                if (fieldNameMap.containsKey(fieldName)) {
                    data.put(fieldNameMap.get(fieldName), structure.getValue(fieldName));
                }
            }

            if (logger.isDebugEnabled()) {
            	logger.debug("#### RFC Export Structure({}) TableData >>> {}", structureName, data);
            }
        }


        return data;
    }
    
    /**
     * RFC Export Table에서 data 추출하기
     * 
     * @param function
     * @param tableName
     * @param fieldNameMap Map<RFC_PARAM_NAME, EHR_PARAM_NAME>
     * @return
     */
    public static List<Map<String, Object>> getTableData(JCoFunction function, String tableName, Map<String, String> fieldNameMap) {
        
        JCoTable table = function.getTableParameterList().getTable(tableName);
        if (logger.isDebugEnabled()) {
        	logger.debug("#### RFC Export Table({}) NumRows  >>> {}", tableName, table.getNumRows());
        	logger.debug("#### RFC Export Table({}) MetaData >>> {}", tableName, table.getMetaData());
        }
        
        List<Map<String, Object>> tableData = new ArrayList<Map<String, Object>>();
        if (table != null && !table.isEmpty()) {
            List<String> fieldNames = new ArrayList<String>();
            
            JCoFieldIterator fieldIter = table.getFieldIterator();
            while (fieldIter.hasNextField()) {
                fieldNames.add(fieldIter.nextField().getName());
            }
            if (logger.isDebugEnabled()) {
            	logger.debug("#### RFC Export Table({}) FieldNames >>> {}", tableName, fieldNames);
            }

            for (int i = 0; i < table.getNumRows(); i++) {
                table.setRow(i);
                
                Map<String, Object> recordData = new HashMap<String, Object>();
                for (String fieldName : fieldNames) {
                    if (fieldNameMap.containsKey(fieldName)) {
                        recordData.put(fieldNameMap.get(fieldName), table.getValue(fieldName));
                    }
                }
                
                tableData.add(recordData);
            }

            if (logger.isDebugEnabled()) {
            	logger.debug("#### RFC Export Table({}) TableData >>> {}", tableName, tableData);
            }
        }
        
        return tableData;
    }
    
    /**
     * RFC Export Table에서 data 추출하기
     * 
     * @param function
     * @param tableName
     * @return
     */
    public static List<Map<String, Object>> getTableData(JCoFunction function, List<String> exportParamNames, String tableName) {
        
        JCoTable table = function.getTableParameterList().getTable(tableName);
        if (logger.isDebugEnabled()) {
        	logger.debug("#### RFC Export Table({}) NumRows  >>> {}", tableName, table.getNumRows());
        	logger.debug("#### RFC Export Table({}) MetaData >>> {}", tableName, table.getMetaData());
        }
        
        List<Map<String, Object>> tableData = new ArrayList<Map<String, Object>>();
        if (table != null && !table.isEmpty()) {
            List<String> fieldNames = new ArrayList<String>();
            
            JCoFieldIterator fieldIter = table.getFieldIterator();
            while (fieldIter.hasNextField()) {
                fieldNames.add(fieldIter.nextField().getName());
            }
            if (logger.isDebugEnabled()) {
            	logger.debug("#### RFC Export Table({}) FieldNames >>> {}", tableName, fieldNames);
            }
            
            for (int i = 0; i < table.getNumRows(); i++) {
                table.setRow(i);
                
                Map<String, Object> recordData = new HashMap<String, Object>();
                for (String fieldName : fieldNames) {
                    recordData.put(fieldName, table.getValue(fieldName));
                }
                
                tableData.add(recordData);
            }
            if (logger.isDebugEnabled()) {
            	logger.debug("#### RFC Export Table({}) TableData >>> {}", tableName, tableData);
            }
        }
        
        return tableData;
    }
}
