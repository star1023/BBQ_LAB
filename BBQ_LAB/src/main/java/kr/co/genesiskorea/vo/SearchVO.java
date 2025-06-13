package kr.co.genesiskorea.vo;

public class SearchVO extends PageVO{
	private String searchType;
	private String searchValue;
	/** 페이징 시작 row */
	private int startRow;
	/** 페이징 종료 row */
	private int endRow;
	
	public String getSearchType() {
		return searchType;
	}

	public void setSearchType(String searchType) {
		this.searchType = searchType;
	}
	
	public String getSearchValue() {
		return searchValue;
	}

	public void setSearchValue(String searchValue) {
		this.searchValue = searchValue;
	}
	
	public int getStartRow() {
		this.startRow = ((this.getPageNo() - 1) * this.getRowSize() + 1);
		return startRow;
	}

	public void setStartRow(int startRow) {
		this.startRow = startRow;
	}

	public int getEndRow() {
		this.endRow = (this.getStartRow() + this.getRowSize() - 1);
		return endRow;
	}

	public int getBoardNo(int totalCnt) {
		return totalCnt - (getPageNo() - 1) * getBlockSize();
	}
}
