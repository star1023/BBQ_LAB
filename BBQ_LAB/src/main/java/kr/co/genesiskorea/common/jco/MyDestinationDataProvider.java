package kr.co.genesiskorea.common.jco;


import java.util.Properties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.sap.conn.jco.ext.DestinationDataEventListener;
import com.sap.conn.jco.ext.DestinationDataProvider;

/*
 * Provides the data connection to the SAP system
 * 
 */
public class MyDestinationDataProvider implements DestinationDataProvider {
	private static final Logger logger = LoggerFactory.getLogger(MyDestinationDataProvider.class);
	
	static String SAP_SERVER = "SAP_SERVER";
	private DestinationDataEventListener eventListener;
	private Properties ABAP_AS_properties;

	public Properties getDestinationProperties(String arg0) {
		return ABAP_AS_properties;
	}

	public void setDestinationDataEventListener(
			DestinationDataEventListener eventListener) {
		this.eventListener = eventListener;
	}
 
	public boolean supportsEvents() {
		return true;
	}

	public void changePropertiesForABAP_AS(Properties properties) {
		logger.info("properties : " + properties);
		if (properties == null) {
			eventListener.deleted("SAP_SERVER");
			ABAP_AS_properties = null;
		} else {
			
			if (ABAP_AS_properties != null && !ABAP_AS_properties.equals(properties)){
				eventListener.updated("SAP_SERVER");
			}
			ABAP_AS_properties = properties;
			logger.info(" ABAP_AS_properties : " + ABAP_AS_properties);
		}
	}
}


