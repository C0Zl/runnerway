package chuchu.runnerway.oauth.controller;

import chuchu.runnerway.member.exception.MemberDuplicateException;
import chuchu.runnerway.member.exception.ResignedMemberException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import chuchu.runnerway.oauth.dto.AlreadySignUpResponseDto;
import chuchu.runnerway.oauth.dto.KakaoMemberResponseDto;
import chuchu.runnerway.oauth.service.KakaoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequestMapping("/oauth")
@RestController
@RequiredArgsConstructor
public class OAuthController {

    private final KakaoService kakaoService;
    private final ObjectMapper objectMapper;

    @Operation(
        summary = "카카오 회원가입 요청",
        description = "카카오 회원가입 할 때 사용하는 API, 이메일을 넘겨줘야함")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "mail이 담긴 객체를 넘겨줌, 프론트는 이제 기존 서비스 회원가입을 진행해야함",
            content = @Content(mediaType = "application/json")
        ),
        @ApiResponse(
            responseCode = "303",
            description = "이미 가입되어 있는 회원임. Access Token을 넘겨주니 이를 저장하고 메인페이지로 이동해야함",
            content = @Content(mediaType = "application/json")
        )
    })
    @PostMapping("/kakao/{email}")
    public ResponseEntity<?> kakaoSignUp(@PathVariable("email") String email) {
        KakaoMemberResponseDto kakaoMemberResponseDto = kakaoService.getKakaoUser(email);
        return ResponseEntity.status(HttpStatus.OK).body(kakaoMemberResponseDto);
    }

    @ExceptionHandler({MemberDuplicateException.class, ResignedMemberException.class})
    public ResponseEntity<?> alreadySignUp(RuntimeException e)
        throws JsonProcessingException {
        AlreadySignUpResponseDto alreadySignUpResponseDto = new AlreadySignUpResponseDto(
            303,
            "이미 소셜회원가입이 된 아이디 입니다.",
            e.getMessage(),
            LocalDateTime.now()
        );

        String responseBody = objectMapper.writeValueAsString(alreadySignUpResponseDto);
        return ResponseEntity.status(303)
            .contentType(MediaType.APPLICATION_JSON)
            .body(responseBody);
    }
}
