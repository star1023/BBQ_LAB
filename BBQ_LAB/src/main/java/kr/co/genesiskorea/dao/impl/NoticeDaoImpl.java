package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.NoticeDao;

@Repository
public class NoticeDaoImpl implements NoticeDao {
	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;

	@Override
    public int selectNoticeCount(Map<String, Object> param) {
        return sqlSessionTemplate.selectOne("notice.selectNoticeCount", param);
    }

    @Override
    public List<Map<String, Object>> selectNoticeList(Map<String, Object> param) {
        return sqlSessionTemplate.selectList("notice.selectNoticeList", param);
    }

    @Override
    public Map<String, Object> selectNoticeData(Map<String, Object> param) {
        return sqlSessionTemplate.selectOne("notice.selectNoticeData", param);
    }

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("notice.selectHistory", param);
	}

	@Override
	public int selectNoticeSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("notice.selectNoticeSeq");
	}
	
    @Override
    public void insertNotice(Map<String, Object> param) throws Exception {
    	sqlSessionTemplate.insert("notice.insertNotice", param);
    }

	@Override
	public void updateNotice(Map<String, Object> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("notice.updateNotice", param);
	}
	
	@Override
	public int updateHits(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.update("notice.updateHits", param);
	};
	
	@Override
	public void updateIsDeleteY(Map<String, Object> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("notice.updateIsDeleteY", param);
	}
}
