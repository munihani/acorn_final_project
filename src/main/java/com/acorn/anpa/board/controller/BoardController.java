package com.acorn.anpa.board.controller;

import java.sql.SQLException;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.acorn.anpa.board.domain.Board;
import com.acorn.anpa.board.service.BoardService;
import com.acorn.anpa.cmn.Message;
import com.acorn.anpa.cmn.PLog;
import com.acorn.anpa.cmn.Search;
import com.acorn.anpa.cmn.StringUtil;
import com.acorn.anpa.code.domain.Code;
import com.acorn.anpa.code.service.CodeService;
import com.acorn.anpa.member.domain.Member;

@Controller
@RequestMapping("board")
public class BoardController implements PLog{
	@Autowired
	BoardService boardService;
	
	@Autowired
	CodeService codeService;
	
	public BoardController() {
		log.debug("┌─────────────────────────");
		log.debug("│ BoardController()");
		log.debug("└─────────────────────────");	
	}
	
	@RequestMapping(
		    value = "/doSelectOne.do",
		    method = RequestMethod.GET
		)
		public String doSelectOne(Board inVO, Model model, HttpServletRequest req) throws SQLException {
		    String viewName = "board/board_info";

		    // 요청 파라미터에서 boardSeq 값을 가져와서 int로 변환
		    int boardSeq = Integer.parseInt(StringUtil.nvl(req.getParameter("seq"), "0"));
		    inVO.setBoardSeq(boardSeq);

		    // HttpSession 객체를 얻어오기
		    HttpSession session = req.getSession(false); // false: 세션이 존재하지 않으면 새로 생성하지 않음
		    
		    // 로그인 사용자 정보 가져오기
		    Member loginUser = null;
		    if (session != null) {
		        loginUser = (Member) session.getAttribute("user");
		    }
		    
		    String regId = "";
		    if (loginUser != null) {
		        regId = loginUser.getUserId(); // 로그인된 사용자 ID를 regId에 저장
		    }
		    inVO.setRegId(regId);

		    // 게시글 조회
		    Board outVO = boardService.doSelectOne(inVO);
		    log.debug("outVO : " + outVO);

		    String message = "";
		    int flag = 0;

		    if (outVO != null) {
		        message = outVO.getTitle() + " 게시글이 조회되었습니다.";
		        flag = 1;
		    } else {
		        message = "조회 실패!";
		    }

		    // Message 객체 생성
		    Message messageObj = new Message(flag, message);

		    // 모델에 데이터 추가
		    model.addAttribute("board", outVO);
		    model.addAttribute("message", messageObj);

		    return viewName;
		}
	
	@GetMapping("/{div}")
	public String doRetrieve(@PathVariable("div")String div, Model model, HttpServletRequest req) throws SQLException {
		String viewName = "board/board";
		
		Search search = new Search();
		
		String searchDiv = StringUtil.nvl(req.getParameter("searchDiv"), "");
		search.setSearchDiv(searchDiv);
		
		String searchWord = StringUtil.nvl(req.getParameter("searchWord"), "");
		search.setSearchWord(searchWord);
		
		//pageSize=10 (기본값)
		String pageSize = StringUtil.nvl(req.getParameter("pageSize"), "10");		
		//pageNo=1 (기본값)
		String pageNo = StringUtil.nvl(req.getParameter("pageNo"), "1");
				
		//div값이 없으면 전체 조회
		String NmDiv = div.replace(".do", "");
		NmDiv = StringUtil.nvl(NmDiv, "");
		log.debug("Received div: " + NmDiv); 
		search.setDiv(NmDiv);
		
		String blTitle;
		if ("20".equals(NmDiv)) {
			blTitle = "공지사항";
		}else {
			blTitle = "소통마당"; // 기본 메시지
		} 
		model.addAttribute("blTitle", blTitle);
		
		List<Board> list = boardService.doRetrieve(search);
		log.debug("list : " + list);
		
		model.addAttribute("list", list);
		model.addAttribute("search", search);
		
		
		//============================================
		Code code = new Code();
		code.setMasterCode("BOARD_SEARCH");
		List<Code> boardSearch = codeService.doRetrieve(code);
		model.addAttribute("boardSearch", boardSearch);		
		//============================================
		return viewName;
	}
	
}
