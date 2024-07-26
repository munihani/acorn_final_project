package com.pcwk.ehr.cmn;

public class Search extends DTO{
	
	private String searchDiv; //검색구분
	private String searchWord;//검색어
	
	private String div; //게시판 구분
	
	public Search() {	}

	public String getSearchDiv() {
		return searchDiv;
	}

	public void setSearchDiv(String searchDiv) {
		this.searchDiv = searchDiv;
	}

	public String getSearchWord() {
		return searchWord;
	}

	public void setSearchWord(String searchWord) {
		this.searchWord = searchWord;
	}

	
	
	public String getDiv() {
		return div;
	}

	public void setDiv(String div) {
		this.div = div;
	}

	@Override
	public String toString() {
		return "Search [searchDiv=" + searchDiv + ", searchWord=" + searchWord + ", div=" + div + ", toString()="
				+ super.toString() + "]";
	}
	
	
}
