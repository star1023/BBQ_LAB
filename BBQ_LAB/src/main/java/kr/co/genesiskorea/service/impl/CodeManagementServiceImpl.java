package kr.co.genesiskorea.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.co.genesiskorea.dao.CodeManagementDao;
import kr.co.genesiskorea.service.CodeManagementService;

@Service
public class CodeManagementServiceImpl implements CodeManagementService {
	
	@Autowired 
	CodeManagementDao codeManagementDao;
	
	@Override
	public List<HashMap<String, Object>> getGroupList() {
		// TODO Auto-generated method stub
		return codeManagementDao.getGroupList();
	}

	@Override
	public int groupCount(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		return codeManagementDao.groupCount(param);
	}

	@Override
	@Transactional
	public void groupInsert(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		codeManagementDao.groupInsert(param);
	}

	@Override
	public void groupUpdate(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		codeManagementDao.groupUpdate(param);
	}

	@Override
	public int groupItemCount(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		return codeManagementDao.groupItemCount(param);
	}

	@Override
	@Transactional
	public void groupDelete(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		codeManagementDao.groupDelete(param);
	}

	@Override
	public List<HashMap<String, Object>> getItemList(Map<String, String> param) {
		// TODO Auto-generated method stub
		return codeManagementDao.getItemList(param);
	}

	@Override
	public int itemCount(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		return codeManagementDao.itemCount(param);
	}

	@Override
	public void itemInsert(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		codeManagementDao.itemInsert(param);
	}

	@Override
	public void itemUpdate(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		codeManagementDao.itemUpdate(param);
	}

	@Override
	public void itemOrderUpdate(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		codeManagementDao.itemOrderUpdate(param);
	}

	@Override
	public void itemDelete(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		codeManagementDao.itemDelete(param);
	}

	@Override
	public void itemOrderUpDown(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		codeManagementDao.itemOrderUpDown(param);
	}

	@Override
	public void itemOrderUpdateAjax(Map<String, String> param, HttpServletRequest request) {
		// TODO Auto-generated method stub
		codeManagementDao.itemOrderUpdateAjax(param);
	}

}
