package kr.co.genesiskorea.common.jco;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.sap.conn.jco.JCoDestination;
import com.sap.conn.jco.JCoDestinationManager;
import com.sap.conn.jco.JCoException;
import com.sap.conn.jco.JCoFunction;
import com.sap.conn.jco.JCoParameterList;

import kr.co.genesiskorea.controller.TestController;

public final class RfcManager {
	private static Logger logger = LogManager.getLogger(RfcManager.class);

	private static String ABAP_AS_POOLED = "SAP_SERVER";

	//private static JCOProvider provider = null;

	private static JCoDestination destination = null;
	/*
	@Autowired
	private static Properties globalProperties;
	static {
		Properties properties = globalProperties;

		provider = new JCOProvider();

		// catch IllegalStateException if an instance is already registered
		try {
			Environment.registerDestinationDataProvider(provider);
		} catch (IllegalStateException e) {			
			logger.debug(e.toString());
		}

		provider.changePropertiesForABAP_AS(ABAP_AS_POOLED, properties);
	}

	public static Properties loadProperties() {
		RfcManager manager = new RfcManager();
		Properties prop = new Properties();
		try {
			prop.load(manager.getClass().getResourceAsStream(
					"/sap_conf.properties"));
		} catch (IOException e) {
			logger.debug(e.toString());
		}
		return prop;
	}*/

	public static JCoDestination getDestination() throws JCoException {
		if (destination == null) {
			destination = JCoDestinationManager.getDestination(ABAP_AS_POOLED);
		}
		return destination;
	}

	public static JCoFunction getFunction(String functionName) {
		JCoFunction function = null;
		try {
			function = getDestination().getRepository()
					.getFunctionTemplate(functionName).getFunction();
		} catch (JCoException e) {
			logger.error(e.toString());
		} catch (NullPointerException e) {
			logger.error(e.toString());
		}
		return function;
	}

	public static void execute(JCoFunction function) {
		logger.debug("SAP Function Name : " + function.getName());
		JCoParameterList paramList = function.getImportParameterList();
		
		if(paramList != null){
			logger.debug("Function Import Structure : "
					+ paramList.toString());
		}

		try {
			function.execute(getDestination());
		} catch (JCoException e) {
			logger.debug(e.toString());
		}
		paramList =function.getExportParameterList();
		
		if(paramList != null){
			logger.debug("Function Export Structure : "
					+ paramList.toString());
		}
	}

	/*
	 * SAP 연결테스트
	 */
	public static String ping() {
		String msg = null;
		try {
			getDestination().ping();
			msg = "Destination " + ABAP_AS_POOLED + " works";
		} catch (JCoException ex) {
			//msg = StringUtil.getExceptionTrace(ex);
			msg = ex.getMessage();
		}
		logger.debug(msg);
		return msg;
	}

	public static void main(String[] args) {
		RfcManager.ping();
	}
}
