package kr.co.genesiskorea.util;

import java.util.Map;

import kr.co.genesiskorea.util.StringUtil;
import kr.co.genesiskorea.vo.SearchVO;

public class PageNavigator {
	private String aClass = "";
	private int blockSize;
	private int endPageNo;
	private String functionName = "paging";
	private int lastPageNo;
	private int pageNo;
	private int startPageNo;
	private int totalCount;
	private int rowCount;
	
	public PageNavigator(int pageNo, int totalCount, int rowCount, int blockSize, String functionName)
			throws Exception {
		this.functionName = functionName;
		init(pageNo, totalCount, rowCount, blockSize);
	}

	public PageNavigator(int pageNo, int totalCount, int rowCount, int blockSize) throws Exception {
		init(pageNo, totalCount, rowCount, blockSize);
	}

	public PageNavigator(SearchVO searchVO, int totalCount, String functionName) throws Exception {
		this.functionName = functionName;
		init(searchVO.getPageNo(), totalCount, searchVO.getRowSize(), searchVO.getBlockSize());
	}

	public PageNavigator(SearchVO searchVO, int totalCount) throws Exception {
		init(searchVO.getPageNo(), totalCount, searchVO.getRowSize(), searchVO.getBlockSize());
	}

	public PageNavigator(Map<String, Object> param, int totalCount) throws Exception {
		SearchVO searchVO = new SearchVO();
		String pageNo = StringUtil.nvl((String) param.get("pageNo"), "1");
		searchVO.setPageNo(Integer.parseInt(pageNo));

		param.put("startRow", searchVO.getStartRow());
		param.put("endRow", searchVO.getEndRow());

		init(searchVO.getPageNo(), totalCount, searchVO.getRowSize(), searchVO.getBlockSize());
	}
	
	public PageNavigator(Map<String, Object> param, int rowCount, int totalCount) throws Exception {
		SearchVO searchVO = new SearchVO();
		String pageNo = StringUtil.nvl((String) param.get("pageNo"), "1");
		searchVO.setPageNo(Integer.parseInt(pageNo));
		searchVO.setRowSize(rowCount);
		param.put("startRow", searchVO.getStartRow());
		param.put("endRow", searchVO.getEndRow());

		init(searchVO.getPageNo(), totalCount, searchVO.getRowSize(), searchVO.getBlockSize());
	}
	
	private void init(int pageNo, int totalCount, int rowCount, int blockSize) {
		this.pageNo = pageNo;
		this.totalCount = totalCount;
		this.blockSize = blockSize;
		this.rowCount = rowCount;
		if (totalCount == 0) {
			return;
		}
		this.lastPageNo = (totalCount / rowCount);
		if (totalCount % rowCount > 0) {
			this.lastPageNo += 1;
		}
		this.startPageNo = ((pageNo - 1) / blockSize * blockSize + 1);
		this.endPageNo = (this.startPageNo + blockSize - 1);
	}

	public String getFirstPage() {
		return getFirstPage("처음");
	}

	public String getFirstPage(String imageTag) {
		if (this.totalCount == 0) {
			return "";
		}
		String strTag = imageTag;
		if (this.pageNo > 0) {
			strTag = "<li><a href='#none' class='btn btn_first' onclick='javascript:" + this.functionName
					+ "(1); return false;'>" + imageTag + "</a></li>";
		}
		return strTag;
	}

	public String getLastPage() {
		return getLastPage("마지막");
	}

	public String getLastPage(String imageTag) {
		if (this.totalCount == 0) {
			return "";
		}
		String strTag = imageTag;
		if (this.pageNo < this.lastPageNo) {
			strTag = "<li><a href='#none' class='btn btn_last' onclick='javascript:" + this.functionName + "("
					+ this.lastPageNo + "); return false;'>" + imageTag + "</a></li>";
		} else {
			strTag = "<li><a href='#none' class='btn btn_last'>" + imageTag + "</a><li>";
		}
		return strTag;
	}

	public int getLastPageNo() {
		return this.lastPageNo;
	}

	public String getNextBlock() {
		return getNextBlock("Next");
	}

	public String getNextBlock(String imageTag) {
		if (this.totalCount == 0) {
			return "";
		}
		String strTag = imageTag;
		if (this.endPageNo < this.lastPageNo) {
			int nextBlockPageNo = this.startPageNo + this.blockSize;
			if (nextBlockPageNo > this.lastPageNo) {
				nextBlockPageNo = this.lastPageNo;
			}
			strTag = "<li style=''><a href='#none' class='btn btn_next3' onclick='javascript:"
					+ this.functionName + "(" + nextBlockPageNo + ", 1); return false;'>" + imageTag + "</a></li>";
		} else {
			//strTag = "<li style='border-right: none;'><a href='#none' class='btn btn_next3'>" + imageTag + "</a></li>";
			strTag = "";
		}
		return strTag + "</ul>";
	}

	public String getPageList() {
		return getPageList("", false);
	}

	public String getPageList(boolean type) {
		return getPageList("", type);
	}

	public String getPageList(String delim) {
		return getPageList(delim, false);
	}

	public String getPageList(String delim, boolean type) {
		if (this.totalCount == 0) {
			return "";
		}

		String strTag = "";
		for (int i = this.startPageNo; i <= this.endPageNo; ++i) {
			if (i > this.lastPageNo) {
				break;
			}

			String pageMark = Integer.toString(i);
			if (type) {
				pageMark = "[" + pageMark + "]";
			}

			if (i == this.pageNo) {
				strTag = strTag + "<li class='select'><a href='#none'>" + pageMark + "</a></li>";
			} else {
				strTag = strTag + "<li><a href='#none' onclick='javascript:" + this.functionName + "(" + i
						+ "); return false;'>" + pageMark + "</a></li>";
			}

			if ((i < this.endPageNo) && (i < this.lastPageNo)) {
				strTag = strTag + " " + delim + " ";
			}
		}

		return strTag;
	}

	public String getPrevBlock() {
		return getPrevBlock("Prev");
	}

	public String getPrevBlock(String imageTag) {
		if (this.totalCount == 0) {
			return "";
		}
		String strTag = imageTag;

		int startBlockPage = (this.startPageNo - 1) / this.blockSize * this.blockSize + 1;

		int prevBlockPage = startBlockPage - 1;

		if (this.pageNo > this.blockSize) {
			strTag = "<li><a href='#none' class='btn btn_prev3' onclick='javascript:" + this.functionName + "("
					+ prevBlockPage + "); return false;'>" + imageTag + "</a></li>";
		} else {
			//strTag = "<li><a href='#none' class='btn btn_prev3'>" + imageTag + "</a></li>";
			strTag = "";
		}
		return "<ul>" + strTag;
	}

	public void setAnchorClass(String className) {
		this.aClass = " class=" + className;
	}

	public void setFunctionName(String functionName) {
		this.functionName = functionName;
	}

	public int getTotalCount() {
		return this.totalCount;
	}

	public int getPageNo() {
		return this.pageNo;
	}

	public int getRowCount() {
		return this.rowCount;
	}

	public String getAclass() {
		return aClass;
	}

	public int getBoardStartNo() {
		return this.totalCount - (this.pageNo - 1) * this.rowCount;
	}
}
