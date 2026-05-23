<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="isNotice" value="${content_view.boardType eq 'NOTICE'}" />

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">

<c:choose>
    <c:when test="${isNotice}">
        <title>공지 상세 - ESS-M.S</title>
    </c:when>
    <c:otherwise>
        <title>문의 상세 - ESS-M.S</title>
    </c:otherwise>
</c:choose>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/header.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/board.css">
<script src="${pageContext.request.contextPath}/resources/js/jquery.js"></script>
</head>

<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="board-page">

    <section class="board-hero">
        <c:choose>
            <c:when test="${isNotice}">
                <h1>공지 상세</h1>
                <p>ESS 운영 및 시스템 공지 내용을 확인합니다.</p>
            </c:when>
            <c:otherwise>
                <h1>문의 상세</h1>
                <p>등록된 문의 내용과 관리자 답변을 확인합니다.</p>
            </c:otherwise>
        </c:choose>
    </section>

    <main class="board-container">

        <div class="board-card">

            <div class="detail-header">
                <h2 class="detail-title">
                    <c:if test="${isNotice}">
                        <span class="notice-badge">공지</span>
                    </c:if>
                    ${content_view.boardTitle}
                </h2>

                <div class="detail-meta">
                    <span>작성자: ${content_view.memberName}</span>

                    <span>
                        작성일:
                        <fmt:formatDate value="${content_view.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                    </span>

                    <span>조회수: ${content_view.boardHit}</span>
                </div>
            </div>

            <div class="detail-content">
                ${content_view.boardContent}
            </div>

            <div class="detail-actions">

                <a href="${pageContext.request.contextPath}/${listPath}?pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}&boardType=${content_view.boardType}"
                   class="btn-secondary">
                    목록
                </a>

                <c:choose>
                    <c:when test="${isNotice}">
                        <c:if test="${role == 'ADMIN' or sessionScope.role == 'ADMIN'}">

                            <a href="${pageContext.request.contextPath}/board_modify_view?boardNo=${content_view.boardNo}&pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}&boardType=${content_view.boardType}"
                               class="btn-primary">
                                수정
                            </a>

                            <a href="${pageContext.request.contextPath}/delete?boardNo=${content_view.boardNo}&pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}&boardType=${content_view.boardType}"
                               class="btn-danger"
                               onclick="return confirm('정말 삭제하시겠습니까?');">
                                삭제
                            </a>

                        </c:if>
                    </c:when>

                    <c:otherwise>
                        <c:if test="${loginMemberId == content_view.memberId}">

                            <a href="${pageContext.request.contextPath}/board_modify_view?boardNo=${content_view.boardNo}&pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}&boardType=${content_view.boardType}"
                               class="btn-primary">
                                수정
                            </a>

                            <a href="${pageContext.request.contextPath}/delete?boardNo=${content_view.boardNo}&pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}&boardType=${content_view.boardType}"
                               class="btn-danger"
                               onclick="return confirm('정말 삭제하시겠습니까?');">
                                삭제
                            </a>

                        </c:if>
                    </c:otherwise>
                </c:choose>

            </div>
        </div>

        <c:if test="${not isNotice}">
            <div class="board-card">

                <h3 class="reply-title">관리자 답변</h3>

                <c:choose>
                    <c:when test="${empty commentList}">
                        <div class="reply-card">
                            <div class="reply-content">
                                아직 등록된 관리자 답변이 없습니다.
                            </div>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <c:forEach var="comment" items="${commentList}">

                            <div class="reply-card">

                                <div class="reply-top">
                                    <div class="reply-writer">관리자</div>

                                    <div class="reply-date">
                                        <fmt:formatDate value="${comment.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                    </div>
                                </div>

                                <div class="reply-content" id="comment-content-${comment.commentId}">
                                    ${comment.commentContent}
                                </div>

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
        </c:if>

    </main>
</div>

<%@ include file="/WEB-INF/views/footer.jsp" %>

<c:if test="${not isNotice}">
<script>
function commentWrite(boardNo) {
    var commentContent = $("#commentContent").val();

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
        error: function() {
            alert("답변 등록 중 서버 오류가 발생했습니다.");
        }
    });
}

function showCommentModify(commentId) {
    $("#comment-modify-box-" + commentId).show();
}

function hideCommentModify(commentId) {
    $("#comment-modify-box-" + commentId).hide();
}

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
        error: function() {
            alert("답변 수정 중 서버 오류가 발생했습니다.");
        }
    });
}

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
        error: function() {
            alert("답변 삭제 중 서버 오류가 발생했습니다.");
        }
    });
}
</script>
</c:if>

</body>
</html>