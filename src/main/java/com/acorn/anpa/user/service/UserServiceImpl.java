package com.acorn.anpa.user.service;

import java.sql.SQLException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.acorn.anpa.mapper.UserMapper;
import com.acorn.anpa.member.domain.Member;
import com.acorn.anpa.user.service.UserService;
import com.acorn.anpa.cmn.PLog;

@Service
public class UserServiceImpl implements PLog, UserService {

    private final UserMapper userMapper;

    // 생성자 주입을 통해 UserMapper 주입
    @Autowired
    public UserServiceImpl(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    @Override
    public Member login(String userId, String password) throws SQLException {
        // 유효성 검사 (예: userId와 password가 null 또는 빈 문자열이 아닌지 확인)
        if (userId == null || userId.isEmpty() || password == null || password.isEmpty()) {
            throw new IllegalArgumentException("User ID and Password must not be null or empty");
        }
        // UserMapper를 이용해 로그인 처리
        return userMapper.login(userId, password);
    }

    @Override
    public int signUp(Member member) throws SQLException {
        // 유효성 검사
        if (member == null || member.getUserId() == null || member.getUserId().isEmpty()) {
            throw new IllegalArgumentException("Member or User ID must not be null or empty");
        }
        // 중복 체크
        if (!idCheck(member.getUserId())) {
            throw new IllegalStateException("User ID is already taken");
        }
        // 회원가입 처리
        return userMapper.signUp(member);
    }

    @Override
    public boolean idCheck(String userId) throws SQLException {
        // 유효성 검사
        if (userId == null || userId.isEmpty()) {
            throw new IllegalArgumentException("User ID must not be null or empty");
        }
        // ID 중복 체크
        return userMapper.idCheck(userId) == 0;
    }

    @Override
    public String findUserId(String userName, String email) throws SQLException {
        // 유효성 검사
        if (userName == null || userName.isEmpty() || email == null || email.isEmpty()) {
            throw new IllegalArgumentException("User name and email must not be null or empty");
        }
        // 아이디 찾기
        return userMapper.findUserId(userName, email);
    }

    @Override
    public String findPassword(String userId, String userName, String email) throws SQLException {
        // 유효성 검사
        if (userId == null || userId.isEmpty() || userName == null || userName.isEmpty() || email == null || email.isEmpty()) {
            throw new IllegalArgumentException("User ID, name, and email must not be null or empty");
        }
        // 비밀번호 찾기
        return userMapper.findPassword(userId, userName, email);
    }


    @Override
    public String generateTemporaryPassword(String userId, String userName, String email) throws SQLException {
        //비밀번호 재설정
    	if (userId == null || userId.isEmpty() || userName == null || userName.isEmpty() || email == null || email.isEmpty()) {
            throw new IllegalArgumentException("User ID, name, and email must not be null or empty");
        }
        String tempPassword = generateRandomPassword();
        userMapper.resetPassword(userId, tempPassword);
        sendTemporaryPasswordEmail(email, tempPassword);
        return tempPassword;
    }

    @Override
    public boolean resetPassword(String token, String newPassword) throws SQLException {
        //비밀번호 재설정
    	if (token == null || token.isEmpty() || newPassword == null || newPassword.isEmpty()) {
            throw new IllegalArgumentException("Token and new password must not be null or empty");
        }
		/*
		 * boolean isTokenValid = userMapper.findPassword(token); if (!isTokenValid) {
		 * return false; }
		 */
        userMapper.resetPassword(token, newPassword);
        return true;
    }

    private String generateRandomPassword() {
        return "temporaryPassword123"; // 예시
    }

    private void sendTemporaryPasswordEmail(String email, String tempPassword) {
        // 이메일 전송 로직
    }
    
    @Override
    public void deleteAll() throws SQLException {
        // 모든 회원 삭제
        userMapper.deleteAll();
    }
    
}