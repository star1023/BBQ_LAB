package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.SystemDocTransferDao;

@Repository
public class SystemDocTransferDaoImpl implements SystemDocTransferDao{
	
	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public List<Map<String, Object>> selectUserDocs(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("systemDocTransfer.selectUserDocs", param);
	}
	
    @Override
    public int updateOwnerByDocNoBulk(Map<String, Object> param) {
        return sqlSessionTemplate.update("systemDocTransfer.updateOwnerByDocNoBulk", param);
    }

    @Override
    public int updateOwnerByIdxBulk(Map<String, Object> param) {
        return sqlSessionTemplate.update("systemDocTransfer.updateOwnerByIdxBulk", param);
    }
    
    @Override
    public int insertTransferHistory(Map<String, Object> param) {
        return sqlSessionTemplate.insert("systemDocTransfer.insertTransferHistory", param);
    }

    @Override
    public int insertTransferDocBulk(Map<String, Object> param) {
        return sqlSessionTemplate.insert("systemDocTransfer.insertTransferDocBulk", param);
    }
	
}
