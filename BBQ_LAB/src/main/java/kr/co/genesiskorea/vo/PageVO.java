package kr.co.genesiskorea.vo;

import java.util.Collection;

public class PageVO {
	private Collection<?> objects;

	private int currentPage;

	private int totalCount;

	private int pageNo = 1;

	private int blockSize = 5;

	private int rowSize = 15;

	private int maxPage;

	private int beginUnitPage;

	private int endUnitPage;

	private String search = "";

	private String condition = "";

	// private int firstIndex;
	// private int recordCountPerPage;
	public PageVO() {
		this.pageNo = 1;
		this.blockSize = 10;
		this.rowSize = 10;
		this.search = "";
		this.condition = "";
	}

	public PageVO(Collection<?> objects, int currentPage, int totalCount) {
		this.objects = objects;
		this.totalCount = totalCount;
		this.maxPage = rowSize == 0 ? this.totalCount : (totalCount - 1) / rowSize + 1;
		this.currentPage = currentPage > maxPage ? maxPage : currentPage;
		this.beginUnitPage = ((currentPage - 1) / pageNo) * pageNo + 1;
		this.endUnitPage = beginUnitPage + (pageNo - 1);
	}

	public PageVO(Collection<?> objects, int currentPage, int totalCount, String condition, String search) {
		this(objects, currentPage, totalCount);
		this.condition = condition;
		this.search = search;
	}

	public PageVO(Collection<?> objects, int currentPage, int totalCount, int pageNo, int rowSize) {
		this.pageNo = pageNo;
		this.rowSize = rowSize;
		this.objects = objects;
		this.totalCount = totalCount;
		this.maxPage = rowSize == 0 ? this.totalCount : (totalCount - 1) / rowSize + 1;
		this.currentPage = currentPage > maxPage ? maxPage : currentPage;
		this.beginUnitPage = ((currentPage - 1) / pageNo) * pageNo + 1;
		this.endUnitPage = beginUnitPage + (pageNo - 1);
	}

	public Collection<?> getList() {
		return objects;
	}

	public void setList(Collection<?> val) {
		// not called.
	}

	public boolean hasNextPage() {
		return currentPage < maxPage;
	}

	public boolean hasPreviousPage() {

		return currentPage > 1;

	}

	public int getNextPage() {
		return currentPage + 1;
	}

	public void setNextPage(int val) {
		// not called
	}

	public int getPreviousPage() {
		return currentPage - 1;
	}

	public void setPreviousPage(int val) {
		// not called
	}

	public boolean hasNextpageno() {
		return endUnitPage < maxPage;
	}

	public boolean hasPreviouspageno() {
		return currentPage >= pageNo + 1;
	}

	public int getStartOfNextpageno() {
		return endUnitPage + 1;
	}

	public int getStartOfPreviouspageno() {
		return beginUnitPage - 1;
	}

	public int getPageOfNextpageno() {
		return (currentPage + pageNo < maxPage) ? currentPage + pageNo : maxPage;
	}

	public int getPageOfPreviouspageno() {
		return (currentPage - pageNo > 1) ? currentPage - pageNo : 1;
	}

	public int getCurrentPage() {
		return this.currentPage;
	}

	public int getBeginUnitPage() {
		return this.beginUnitPage;
	}

	public int getEndListPage() {
		return (endUnitPage > maxPage) ? this.maxPage : this.endUnitPage;
	}

	public void setEndListPage(int val) {
		// not called.
	}

	public int getSize() {
		return (this.objects == null || this.getSize() == 0) ? 0 : objects.size();
	}

	public boolean isEmptyPage() {
		return (this.objects == null || this.getSize() == 0) ? true : false;
	}

	public void setEmptyPage(boolean val) {
		// not called.
	}

	public int getTotal() {
		return this.totalCount;
	}

	public void setTotal(int val) {
		// not called.
	}

	public String getCurrentPageStr() {
		return (new Integer(this.currentPage)).toString();
	}

	public void setCurrentPageStr(String str) {
		// not called.
	}

	public String getCondition() {
		return condition;
	}

	public void setCondition(String condition) {
		this.condition = condition;
	}

	public String getSearch() {
		return search;
	}

	public void setSearch(String search) {
		this.search = search;
	}

	public int getBlockSize() {
		return blockSize;
	}

	public void setBlockSize(int blockSize) {
		this.blockSize = blockSize;
	}

	public int getRowSize() {
		return rowSize;
	}

	public void setRowSize(int rowSize) {
		this.rowSize = rowSize;
	}

	public Collection<?> getObjects() {
		return objects;
	}

	public void setObjects(Collection<?> objects) {
		this.objects = objects;
	}

	public int getTotalCount() {
		return totalCount;
	}

	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}

	public int getPageNo() {
		return pageNo;
	}

	public void setPageNo(int pageNo) {
		this.pageNo = pageNo;
	}

	public int getMaxPage() {
		return maxPage;
	}

	public void setMaxPage(int maxPage) {
		this.maxPage = maxPage;
	}

	public int getEndUnitPage() {
		return endUnitPage;
	}

	public void setEndUnitPage(int endUnitPage) {
		this.endUnitPage = endUnitPage;
	}

	public void setCurrentPage(int currentPage) {
		this.currentPage = currentPage;
	}

	public void setBeginUnitPage(int beginUnitPage) {
		this.beginUnitPage = beginUnitPage;
	}

	public int getFirstIndex() {
		return (pageNo - 1) * rowSize;
	}

	public int getRecordCountPerPage() {
		return rowSize;
	}
}
