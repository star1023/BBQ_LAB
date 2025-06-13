package kr.co.genesiskorea.schedule;

import java.util.Calendar;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

import kr.co.genesiskorea.service.BatchService;

public class LabSchedule {
	private Logger logger = LogManager.getLogger(LabSchedule.class);
	
	@Autowired
	BatchService batchService;
	
	public void test() throws Exception {
		Calendar cal = Calendar.getInstance();
		System.err.println(cal.get(Calendar.YEAR)+"-"+cal.get(Calendar.MONTH)+"-"+cal.get(Calendar.DATE)+"  "+cal.get(Calendar.HOUR)+":"+cal.get(Calendar.MINUTE)+":"+cal.get(Calendar.SECOND)+" : �����췯~~~~~~");
	}
	
	public void erpMaterial() throws Exception{
		batchService.erpMaterial();
	}
	
	
	public void initSeq() {
		batchService.initSeq();
	}
}
