package kr.co.genesiskorea.common.jco;

import java.util.Properties;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.sap.conn.jco.JCoContext;
import com.sap.conn.jco.JCoDestination;
import com.sap.conn.jco.JCoDestinationManager;
import com.sap.conn.jco.JCoException;
import com.sap.conn.jco.JCoFunction;
import com.sap.conn.jco.JCoRepository;
import com.sap.conn.jco.ext.DestinationDataProvider;

@Component
public class JcoConnection {
	
	@Autowired
	Properties globalProperties;
	static String SAP_SERVER = "SAP_SERVER";
	private JCoRepository repos;
	private JCoDestination dest;
	private MyDestinationDataProvider myProvider ;
	//public JcoConnection(){}
	public JcoConnection(){
		new JcoConnection(globalProperties);
	}
	public JcoConnection(Properties jcoProperties)
    {
    	try
    	{
	    	Properties connectProperties = new Properties();
	    	connectProperties.setProperty(DestinationDataProvider.JCO_ASHOST, jcoProperties.getProperty("sap.host"));
	    	connectProperties.setProperty(DestinationDataProvider.JCO_SYSNR, jcoProperties.getProperty("sap.systemnumber"));
	    	connectProperties.setProperty(DestinationDataProvider.JCO_CLIENT, jcoProperties.getProperty("sap.client"));
	    	connectProperties.setProperty(DestinationDataProvider.JCO_USER,	jcoProperties.getProperty("sap.user"));
	    	connectProperties.setProperty(DestinationDataProvider.JCO_PASSWD, jcoProperties.getProperty("sap.password"));
	    	connectProperties.setProperty(DestinationDataProvider.JCO_LANG, jcoProperties.getProperty("sap.language"));
	    	connectProperties.setProperty(DestinationDataProvider.JCO_POOL_CAPACITY, jcoProperties.getProperty("sap.pool.capacity"));
	    	connectProperties.setProperty(DestinationDataProvider.JCO_PEAK_LIMIT, jcoProperties.getProperty("sap.pool.limit"));
    		myProvider= new MyDestinationDataProvider();
    		myProvider.changePropertiesForABAP_AS(connectProperties);
    		com.sap.conn.jco.ext.Environment.registerDestinationDataProvider(myProvider);
    		
    		/*try {
    			dest = JCoDestinationManager.getDestination(SAP_SERVER);
    			System.out.println("dest  :  "+dest);
    			repos = dest.getRepository();
    			System.out.println("repos  :  "+repos);

    		} catch (JCoException e) {
    			e.printStackTrace();
    			throw new RuntimeException(e);
    		}*/
    	}catch (Exception e)
    	{
    	}
    } 
	
	/*public JCoFunction getFunction(String functionStr) {
		JCoFunction function = null;
		try {
			function = repos.getFunction(functionStr);
		} catch (Exception e) {
			e.printStackTrace();
			throw new RuntimeException(
					"Problem retrieving JCO.Function object.");
		}
		if (function == null) {
			throw new RuntimeException("Not possible to receive function. ");
		}

		return function;
	}
	
	public void execute(JCoFunction function) {
		try {
			JCoContext.begin(dest);
			function.execute(dest);
			JCoContext.end(dest);

		} catch (JCoException e) {
			e.printStackTrace();
		}
	}
	
	public void end(JCoFunction function) {
		try {
			com.sap.conn.jco.ext.Environment
			.unregisterDestinationDataProvider(myProvider);

		} catch (Exception e) {
			e.printStackTrace();
		}
	}*/
}
