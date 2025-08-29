package kr.co.genesiskorea.schedule;

import java.util.Calendar;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import kr.co.genesiskorea.service.BatchService;

@Component
public class LabSchedule {
	private Logger logger = LogManager.getLogger(LabSchedule.class);
	
	@Autowired
	BatchService batchService;
	
//	@Scheduled(cron = "*/1 * * * * ?")
	public void test() throws Exception {
		Calendar cal = Calendar.getInstance();
		System.err.println(cal.get(Calendar.YEAR)+"-"+cal.get(Calendar.MONTH)+"-"+cal.get(Calendar.DATE)+"  "+cal.get(Calendar.HOUR)+":"+cal.get(Calendar.MINUTE)+":"+cal.get(Calendar.SECOND)+" : �����췯~~~~~~");
		logger.info("스케쥴 테스트");
	}
	
	@Scheduled(cron = "0 0 1 * * ?", zone = "Asia/Seoul")
	public void erpMaterial() throws Exception{
		batchService.erpMaterial();
	}
	
	
	@Scheduled(cron = "0 1 0 1 * ?", zone = "Asia/Seoul")
	public void initSeq() {
		batchService.initSeq();
	}
	
	@Scheduled(cron = "0 10 0 * * ?", zone = "Asia/Seoul")
	public void hrOrgMaster() {
		batchService.hrOrgMaster();
	}
	
	@Scheduled(cron = "0 20 0 * * ?", zone = "Asia/Seoul")
	public void hrUserMaster() {
		batchService.hrUserMaster();
	}
	
	@Scheduled(cron = "0 30 0 * * ?", zone = "Asia/Seoul")
	public void hrCodeMaster() {
		batchService.hrCodeMaster();
	}
	
	@Scheduled(cron = "0 40 0 * * ?", zone = "Asia/Seoul")
	public void hrUserSync() {
		batchService.hrUserSync();
	}
}
