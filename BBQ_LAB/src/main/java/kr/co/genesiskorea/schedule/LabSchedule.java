package kr.co.genesiskorea.schedule;

import java.util.Calendar;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;

import kr.co.genesiskorea.service.BatchService;

public class LabSchedule {
	private Logger logger = LogManager.getLogger(LabSchedule.class);
	
	@Autowired
	BatchService batchService;
	
	public void test() throws Exception {
		Calendar cal = Calendar.getInstance();
		System.err.println(cal.get(Calendar.YEAR)+"-"+cal.get(Calendar.MONTH)+"-"+cal.get(Calendar.DATE)+"  "+cal.get(Calendar.HOUR)+":"+cal.get(Calendar.MINUTE)+":"+cal.get(Calendar.SECOND)+" : �����췯~~~~~~");
	}
	
	@Scheduled(cron = "0 0 1 * * * ?")
	public void erpMaterial() throws Exception{
		batchService.erpMaterial();
	}
	
	
	@Scheduled(cron = "0 1 0 1 * * ?")
	public void initSeq() {
		batchService.initSeq();
	}
	
	@Scheduled(cron = "0 10 0 * * ?")
	public void hrOrgMaster() {
		batchService.hrOrgMaster();
	}
	
	@Scheduled(cron = "0 30 0 * * ?")
	public void hrUserMaster() {
		batchService.hrUserMaster();
	}
	
	@Scheduled(cron = "0 20 0 * * ?")
	public void hrCodeMaster() {
		batchService.hrCodeMaster();
	}
	
	@Scheduled(cron = "0 40 0 * * ?")
	public void hrUserSync() {
		batchService.hrUserSync();
	}
}
