package kr.co.genesiskorea.service.impl;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;

import kr.co.genesiskorea.dao.impl.TestDaoImpl;
import kr.co.genesiskorea.service.TestService;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class TestServiceImpl implements TestService {
	
	@Autowired(required=true)
	TestDaoImpl testDao;
	
	@Resource
	DataSourceTransactionManager txManager;
	
	@Override
	public List<HashMap<String,Object>> selectUser(HashMap<String, Object> map) throws Exception {
		// TODO Auto-generated method stub
		return testDao.selectUser(map);
	}


	@Transactional(rollbackFor = Exception.class)
	public void insertTrText(){
		// TODO Auto-generated method stub
		//DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		//TransactionStatus status = null;
		
		//def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		//status = txManager.getTransaction(def);
		try {
			
			HashMap<String, Object> param = new HashMap<String, Object>();
			param.put("idx", 1);
			param.put("text", "abcd1234");
			testDao.insertTest1(param);
			
			
			param.clear();
			param.put("idx", 1);
			param.put("text", "abcdef123456");
			testDao.insertTest2(param);
			
			//txManager.commit(status);
		} catch( Exception e ) {
			System.err.println(StringUtil.getStackTrace(e, this.getClass()));
			//txManager.rollback(status);
			throw new RuntimeException("강제 예외");
		}		
	}

}
