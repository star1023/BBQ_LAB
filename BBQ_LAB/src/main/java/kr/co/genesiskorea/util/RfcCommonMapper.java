package kr.co.genesiskorea.util;

import java.util.List;
import java.util.Map;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.collections4.MapUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


import com.sap.conn.jco.JCoContext;
import com.sap.conn.jco.JCoDestination;
import com.sap.conn.jco.JCoException;
import com.sap.conn.jco.JCoFunction;
import com.sap.conn.jco.JCoParameterList;
import com.sap.conn.jco.JCoTable;

import kr.co.genesiskorea.common.jco.RfcManager;

public class RfcCommonMapper {
	
	private Logger logger = LoggerFactory.getLogger(RfcCommonMapper.class);
	
	protected JCoFunction getFunction(JCoDestination dest, String functionName) throws Exception {
		JCoFunction function = null;
		try {
			function = dest.getRepository()
					.getFunctionTemplate(functionName).getFunction();
		} catch (JCoException e) {
			logger.error(e.toString());
		} catch (NullPointerException e) {
			logger.error(e.toString());
		}
		return function;
    }
	
	protected void execute(JCoFunction function) throws Exception {
		JCoDestination dest = RfcManager.getDestination();
        try {
            JCoContext.begin(dest);
            function.execute(dest);
        } finally {
            JCoContext.end(dest);
        }
    }
	
	protected void execute(JCoFunction function, Map<String, Object> importParams) throws Exception {
        if (MapUtils.isNotEmpty(importParams)) {
            JCoParameterList importParamList = function.getImportParameterList();
            for (String key : importParams.keySet()) {
                importParamList.setValue(key, importParams.get(key));
            }
        }
        execute(function);
    }
	
	protected void execute(JCoFunction function, Map<String, Object> importParams, String tableName, List<Map<String, Object>> tableParams) throws Exception {
        if (MapUtils.isNotEmpty(importParams)) {
            JCoParameterList importParamList = function.getImportParameterList();
            for (String key : importParams.keySet()) {
                importParamList.setValue(key, importParams.get(key));
            }
        }
        if (CollectionUtils.isNotEmpty(tableParams)) {
            JCoTable table = function.getTableParameterList().getTable(tableName);
            int i = 0;
            table.appendRows(tableParams.size());
            for (Map<String, Object> tableData : tableParams) {
                table.setRow(i++);
                for (String key : tableData.keySet()) {
                    table.setValue(key, tableData.get(key));
                }
            }
        }
        execute(function);
    }
	
}
