<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>문의 상세 - ESS-M.S</title>

<%-- 공통 CSS --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/header.css">

<%-- 게시판 전용 CSS --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/board.css">

<%--
    관리자 답변 등록 AJAX에 jQuery가 필요하다.

    만약 header.jsp 또는 footer.jsp에서 이미 jQuery를 불러오고 있다면
    아래 script는 중복이 될 수 있으므로 제거해도 된다.

    프로젝트에 실제 파일명이 jquery.js라면
    jquery-3.6.0.min.js 대신 jquery.js로 바꿔야 한다.
--%>
<script src="${pageContext.request.contextPath}/resources/js/jquery.js"></script>
</head>

<body>

<%-- 공통 헤더 --%>
<%@ include file="/WEB-INF/views/header.jsp" %>

<%--
    게시판 상세 전체 영역

    board-page:
    - 게시판 목록, 상세, 글쓰기 화면의 배경을 통일하기 위한 wrapper
--%>
<div class="board-page">

    <%--
        상단 소개 영역

        board-hero:
        - 현재 페이지가 문의 상세 화면임을 보여주는 영역
    --%>
    <section class="board-hero">
        <h1>문의 상세</h1>
        <p>등록된 문의 내용을 확인합니다.</p>
    </section>

    <%--
        상세 본문 컨테이너

        board-container:
        - 상세 화면의 최대 너비와 여백을 잡는 영역
    --%>
    <main class="board-container">

        <%--
            문의 본문 카드

            board-card:
            - 제목, 작성자, 작성일, 조회수, 본문 내용을 하나의 카드로 묶음
        --%>
        <div class="board-card">

            <%--
                상세 상단 영역

                detail-header:
                - 제목과 메타정보를 구분하기 위한 영역
            --%>
            <div class="detail-header">

                <%-- 문의 제목 --%>
                <h2 class="detail-title">
                    ${content_view.boardTitle}
                </h2>

                <%--
                    문의 메타정보

                    작성자, 작성일, 조회수 표시
                --%>
                <div class="detail-meta">
                    <span>작성자: ${content_view.memberName}</span>

                    <span>
                        작성일:
                        <fmt:formatDate value="${content_view.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                    </span>

                    <span>조회수: ${content_view.boardHit}</span>
                </div>
            </div>

            <%--
                문의 본문

                CSS의 white-space: pre-line 설정으로
                사용자가 입력한 줄바꿈을 어느 정도 유지한다.
            --%>
            <div class="detail-content">
                ${content_view.boardContent}
            </div>

            <%--
                버튼 영역

                목록:
                - 항상 표시

                수정/삭제:
                - 작성자 본인만 표시
                - sessionScope.member_id 대신 Controller에서 넘긴 loginMemberId 사용
                - 이유: 프로젝트 내 세션명이 memberId/member_id로 섞여 있어도 Controller에서 보정한 값을 쓰기 위해서
            --%>
            <div class="detail-actions">

                <%-- 목록 버튼: cri가 없거나 값이 비어 있어도 500 오류가 나지 않게 방어 --%>
                <c:choose>
                    <c:when test="${empty cri}">
                        <a href="${pageContext.request.contextPath}/board_list" class="btn-secondary">
                            목록
                        </a>
                    </c:when>

                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/board_list?pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}"
                           class="btn-secondary">
                            목록
                        </a>
                    </c:otherwise>
                </c:choose>

                <%--
                    작성자 본인만 수정/삭제 가능

                    기존:
                    sessionScope.member_id == content_view.memberId

                    변경:
                    loginMemberId == content_view.memberId

                    BoardController에서 loginMemberId를 model로 전달하고 있으므로 이 값을 사용한다.
                --%>
                <c:if test="${loginMemberId == content_view.memberId}">

                    <a href="${pageContext.request.contextPath}/board_modify_view?boardNo=${content_view.boardNo}&pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}"
                       class="btn-primary">
                        수정
                    </a>

                    <a href="${pageContext.request.contextPath}/delete?boardNo=${content_view.boardNo}&pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}"
                       class="btn-danger"
                       onclick="return confirm('정말 삭제하시겠습니까?');">
                        삭제
                    </a>

                </c:if>
            </div>
        </div>

        <%--
            관리자 답변 카드

            commentList:
            - Controller에서 관리자 댓글 목록을 model에 담아 전달한 값
        --%>
        <div class="board-card">

            <h3 class="reply-title">관리자 답변</h3>

            <c:choose>

                <%-- 등록된 답변이 없을 때 --%>
                <c:when test="${empty commentList}">
                    <div class="reply-card">
                        <div class="reply-content">
                            아직 등록된 관리자 답변이 없습니다.
                        </div>
                    </div>
                </c:when>

                <%-- 관리자 답변 목록 출력 --%>
                <c:otherwise>
                    <c:forEach var="comment" items="${commentList}">

                        <div class="reply-card">

                            <%--
                                답변 상단 정보

                                현재는 관리자 답변이므로 작성자를 관리자라고 표시한다.
                                DTO에 memberName이 있으면 ${comment.memberName}으로 바꿔도 된다.
                            --%>
                            <div class="reply-top">
                                <div class="reply-writer">관리자</div>

                                <div class="reply-date">
                                    <fmt:formatDate value="${comment.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                </div>
                            </div>

                            <%-- 답변 내용 --%>
                            <div class="reply-content" id="comment-content-${comment.commentId}">
                                ${comment.commentContent}
                            </div>

                            <%--
                                관리자만 댓글 수정/삭제 버튼 표시

                                현재 BoardCommentController에는 /comment_modify, /comment_delete가 이미 있다.
                                여기서는 버튼과 AJAX 함수까지 연결한다.
                            --%>
                            <c:if test="${role == 'ADMIN' or sessionScope.role == 'ADMIN'}">
                                <div class="reply-actions" style="margin-top: 14px; display:flex; gap:8px; justify-content:flex-end;">
                                    <button type="button"
                                            class="btn-secondary"
                                            onclick="showCommentModify(${comment.commentId})">
                                        수정
                                    </button>

                                    <button type="button"
                                            class="btn-danger"
                                            onclick="commentDelete(${comment.commentId})">
                                        삭제
                                    </button>
                                </div>

                                <%-- 댓글 수정 입력 영역: 기본 숨김 --%>
                                <div id="comment-modify-box-${comment.commentId}"
                                     style="display:none; margin-top:14px;">
                                    <textarea id="comment-modify-content-${comment.commentId}"
                                              class="board-textarea">${comment.commentContent}</textarea>

                                    <div class="form-actions" style="margin-top:10px;">
                                        <button type="button"
                                                class="btn-primary"
                                                onclick="commentModify(${comment.commentId})">
                                            수정 완료
                                        </button>

                                        <button type="button"
                                                class="btn-secondary"
                                                onclick="hideCommentModify(${comment.commentId})">
                                            취소
                                        </button>
                                    </div>
                                </div>
                            </c:if>
                        </div>

                    </c:forEach>
                </c:otherwise>
            </c:choose>

            <%--
                관리자 답변 작성 영역

                role이 ADMIN인 경우에만 답변 입력창을 보여준다.

                주의:
                BoardController의 boardContentView()에서
                model.addAttribute("role", role); 이 필요하다.

                혹시 model의 role이 없어도 sessionScope.role이 있으면 보이도록 둘 다 체크한다.
            --%>
            <c:if test="${role == 'ADMIN' or sessionScope.role == 'ADMIN'}">
                <div class="reply-card" style="margin-top: 20px;">

                    <div class="form-group">
                        <label>관리자 답변 작성</label>

                        <textarea id="commentContent"
                                  class="board-textarea"
                                  placeholder="관리자 답변을 입력하세요."></textarea>
                    </div>

                    <div class="form-actions">
                        <button type="button"
                                class="btn-primary"
                                onclick="commentWrite(${content_view.boardNo})">
                            답변 등록
                        </button>
                    </div>

                </div>
            </c:if>
        </div>

    </main>
</div>

<%@ include file="/WEB-INF/views/footer.jsp" %>

<script>
/*
    관리자 답변 등록 AJAX

    요청 URL:
    POST /comment_write

    BoardCommentController.commentWrite()로 연결된다.
*/
function commentWrite(boardNo) {
    console.log("@# commentWrite()");
    console.log("@# boardNo =>", boardNo);

    var commentContent = $("#commentContent").val();

    console.log("@# commentContent =>", commentContent);

    if (commentContent == null || commentContent.trim() == "") {
        alert("답변 내용을 입력하세요.");
        $("#commentContent").focus();
        return;
    }

    $.ajax({
        type: "post",
        url: "${pageContext.request.contextPath}/comment_write",
        data: {
            boardNo: boardNo,
            commentContent: commentContent
        },
        success: function(result) {
            console.log("@# comment write result =>", result);

            if (result == "success") {
                alert("답변이 등록되었습니다.");
                location.reload();

            } else if (result == "login_required") {
                alert("로그인이 필요합니다.");
                location.href = "${pageContext.request.contextPath}/login_view";

            } else if (result == "forbidden") {
                alert("관리자만 답변을 등록할 수 있습니다.");

            } else if (result == "empty") {
                alert("답변 내용을 입력하세요.");

            } else {
                alert("답변 등록에 실패했습니다.");
            }
        },
        error: function(xhr, status, error) {
            console.log("@# xhr.status =>", xhr.status);
            console.log("@# xhr.responseText =>", xhr.responseText);
            console.log("@# status =>", status);
            console.log("@# error =>", error);

            alert("답변 등록 중 서버 오류가 발생했습니다.");
        }
    });
}

/*
    댓글 수정 입력창 열기
*/
function showCommentModify(commentId) {
    $("#comment-modify-box-" + commentId).show();
}

/*
    댓글 수정 입력창 닫기
*/
function hideCommentModify(commentId) {
    $("#comment-modify-box-" + commentId).hide();
}

/*
    관리자 답변 수정 AJAX

    요청 URL:
    POST /comment_modify
*/
function commentModify(commentId) {
    var commentContent = $("#comment-modify-content-" + commentId).val();

    if (commentContent == null || commentContent.trim() == "") {
        alert("답변 내용을 입력하세요.");
        $("#comment-modify-content-" + commentId).focus();
        return;
    }

    $.ajax({
        type: "post",
        url: "${pageContext.request.contextPath}/comment_modify",
        data: {
            commentId: commentId,
            commentContent: commentContent
        },
        success: function(result) {
            console.log("@# comment modify result =>", result);

            if (result == "success") {
                alert("답변이 수정되었습니다.");
                location.reload();

            } else if (result == "login_required") {
                alert("로그인이 필요합니다.");
                location.href = "${pageContext.request.contextPath}/login_view";

            } else if (result == "forbidden") {
                alert("관리자만 답변을 수정할 수 있습니다.");

            } else if (result == "empty") {
                alert("답변 내용을 입력하세요.");

            } else {
                alert("답변 수정에 실패했습니다.");
            }
        },
        error: function(xhr, status, error) {
            console.log("@# xhr.status =>", xhr.status);
            console.log("@# xhr.responseText =>", xhr.responseText);
            console.log("@# status =>", status);
            console.log("@# error =>", error);

            alert("답변 수정 중 서버 오류가 발생했습니다.");
        }
    });
}

/*
    관리자 답변 삭제 AJAX

    요청 URL:
    POST /comment_delete
*/
function commentDelete(commentId) {
    if (!confirm("답변을 삭제하시겠습니까?")) {
        return;
    }

    $.ajax({
        type: "post",
        url: "${pageContext.request.contextPath}/comment_delete",
        data: {
            commentId: commentId
        },
        success: function(result) {
            console.log("@# comment delete result =>", result);

            if (result == "success") {
                alert("답변이 삭제되었습니다.");
                location.reload();

            } else if (result == "login_required") {
                alert("로그인이 필요합니다.");
                location.href = "${pageContext.request.contextPath}/login_view";

            } else if (result == "forbidden") {
                alert("관리자만 답변을 삭제할 수 있습니다.");

            } else {
                alert("답변 삭제에 실패했습니다.");
            }
        },
        error: function(xhr, status, error) {
            console.log("@# xhr.status =>", xhr.status);
            console.log("@# xhr.responseText =>", xhr.responseText);
            console.log("@# status =>", status);
            console.log("@# error =>", error);

            alert("답변 삭제 중 서버 오류가 발생했습니다.");
        }
    });
}
</script>

</body>
</html>