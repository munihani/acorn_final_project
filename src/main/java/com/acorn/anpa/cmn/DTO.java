package com.acorn.anpa.cmn;

/**
 * 모든 Value Object는 DTO를 상속 받아야 한다.
 * @author acorn
 *
 */
public class DTO {
	
	private int totalCnt; //총 글수
	
	private int no;       //글 번호
	
	private int pageSize;//페이지 사이즈
	private int pageNo;//페이지 번호
	public static final int BOTTOM_COUNT = 10; //바닥글
	
	private String regId;//등록자
	private String modId;//수정자
	private String regDt;//등록일
	private String modDt;//수정일
	
	public DTO() {	 
		pageSize = 10;
		pageNo = 1;
	}
	
	public String getRegId() {
		return regId;
	}



	public void setRegId(String regId) {
		this.regId = regId;
	}



	public String getModId() {
		return modId;
	}



	public void setModId(String modId) {
		this.modId = modId;
	}



	public String getRegDt() {
		return regDt;
	}



	public void setRegDt(String regDt) {
		this.regDt = regDt;
	}



	public String getModDt() {
		return modDt;
	}



	public void setModDt(String modDt) {
		this.modDt = modDt;
	}



	public int getPageSize() {
		return pageSize;
	}

	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}

	public int getPageNo() {
		return pageNo;
	}

	public void setPageNo(int pageNo) {
		this.pageNo = pageNo;
	}

	public int getNo() {
		return no;
	}

	public void setNo(int no) {
		this.no = no;
	}

	public int getTotalCnt() {
		return totalCnt;
	}

	public void setTotalCnt(int totalCnt) {
		this.totalCnt = totalCnt;
	}

	@Override
	public String toString() {
		return "DTO [totalCnt=" + totalCnt + ", no=" + no + ", pageSize=" + pageSize + ", pageNo=" + pageNo + ", regId="
				+ regId + ", modId=" + modId + ", regDt=" + regDt + ", modDt=" + modDt + "]";
	}

	
	
}
