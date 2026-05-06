<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>문의 상세 - ESS-M.S</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/header.css">
<script src="${pageContext.request.contextPath}/resources/js/jquery.js"></script>
<style>
.container { width: 80%; margin: 0 auto; }

.sub-hero {
    background-color: #2c3e50;
    color: white;
    padding: 60px 0;
    text-align: center;
}

.detail-section { padding: 50px 0; }

.detail-box {
    border-top: 2px solid #333;
    background: #fff;
}

.detail-title {
    padding: 20px;
    border-bottom: 1px solid #ddd;
}

.detail-title h2 { margin: 0 0 10px; }

.detail-meta {
    color: #666;
    font-size: 0.95rem;
}

.detail-content {
    min-height: 250px;
    padding: 30px 20px;
    border-bottom: 1px solid #ddd;
    line-height: 1.8;
    white-space: pre-wrap;
}

.btn-area {
    margin-top: 25px;
    display: flex;
    gap: 8px;
    justify-content: flex-end;
}

.btn {
    padding: 9px 15px;
    background:#007bff;
    color:white;
    border:none;
    border-radius:5px;
    cursor:pointer;
    text-decoration:none;
}

.btn-gray { background:#6c757d; }
.btn-red { background:#dc3545; }

.comment-area {
    margin-top: 45px;
    border-top: 2px solid #333;
    padding-top: 25px;
}

.comment-area h3 {
    margin-bottom: 20px;
}

.comment-empty {
    padding: 20px;
    background: #f8f9fa;
    border: 1px solid #ddd;
    color: #666;
}

.comment-box {
    padding: 18px;
    margin-bottom: 15px;
    border: 1px solid #ddd;
    background: #fafafa;
    border-radius: 6px;
}

.comment-header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    color: #555;
}

.comment-content {
    line-height: 1.7;
    white-space: pre-wrap;
}

.comment-btn-area,
.comment-edit-btn-area {
    margin-top: 12px;
    display: flex;
    gap: 6px;
    justify-content: flex-end;
}

.comment-btn-area button,
.comment-edit-btn-area button,
.comment-write-box button {
    padding: 7px 12px;
    border: none;
    border-radius: 4px;
    background: #007bff;
    color: white;
    cursor: pointer;
}

.btn-red-small {
    background: #dc3545 !important;
}

.btn-gray-small {
    background: #6c757d !important;
}

.comment-edit-box textarea,
.comment-write-box textarea {
    width: 100%;
    box-sizing: border-box;
    resize: vertical;
    padding: 10px;
}

.comment-write-box {
    margin-top: 25px;
    padding: 20px;
    border: 1px solid #ddd;
    background: #f8f9fa;
    border-radius: 6px;
}

.comment-write-box h4 {
    margin-top: 0;
}
</style>
</head>

<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<section class="sub-hero">
    <div class="container">
        <h2>문의 상세</h2>
        <p>등록된 문의 내용을 확인합니다.</p>
    </div>
</section>

<main class="container detail-section">

    <div class="detail-box">
        <div class="detail-title">
            <h2>${content_view.boardTitle}</h2>

            <div class="detail-meta">
                작성자: ${content_view.memberName}
                |
                작성일:
                <fmt:formatDate value="${content_view.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                |
                조회수: ${content_view.boardHit}
            </div>
        </div>

        <div class="detail-content">${content_view.boardContent}</div>
    </div>

    <div class="btn-area">
        <a class="btn btn-gray"
           href="${pageContext.request.contextPath}/board_list?pageNum=${empty pageMaker.pageNum ? 1 : pageMaker.pageNum}&amount=${empty pageMaker.amount ? 10 : pageMaker.amount}&type=${pageMaker.type}&keyword=${pageMaker.keyword}">
            목록
        </a>

        <c:if test="${loginMemberId == content_view.memberId}">
            <button type="button" class="btn" onclick="showModifyForm()">수정</button>

            <form action="${pageContext.request.contextPath}/delete"
                  method="post"
                  style="display:inline;"
                  onsubmit="return confirm('정말 삭제하시겠습니까?');">

                <input type="hidden" name="boardNo" value="${content_view.boardNo}">
                <input type="hidden" name="pageNum" value="${empty pageMaker.pageNum ? 1 : pageMaker.pageNum}">
                <input type="hidden" name="amount" value="${empty pageMaker.amount ? 10 : pageMaker.amount}">
                <input type="hidden" name="type" value="${pageMaker.type}">
                <input type="hidden" name="keyword" value="${pageMaker.keyword}">

                <button type="submit" class="btn btn-red">삭제</button>
            </form>
        </c:if>
    </div>

    <c:if test="${loginMemberId == content_view.memberId}">
        <div id="modifyForm" style="display:none; margin-top:30px;">
            <form action="${pageContext.request.contextPath}/modify" method="post">

                <input type="hidden" name="boardNo" value="${content_view.boardNo}">
                <input type="hidden" name="pageNum" value="${empty pageMaker.pageNum ? 1 : pageMaker.pageNum}">
                <input type="hidden" name="amount" value="${empty pageMaker.amount ? 10 : pageMaker.amount}">
                <input type="hidden" name="type" value="${pageMaker.type}">
                <input type="hidden" name="keyword" value="${pageMaker.keyword}">

                <div>
                    <label>제목</label>
                    <input type="text" name="boardTitle" value="${content_view.boardTitle}">
                </div>

                <div>
                    <label>내용</label>
                    <textarea name="boardContent" rows="10">${content_view.boardContent}</textarea>
                </div>

                <div>
                    <button type="submit" class="btn">수정 완료</button>
                </div>

            </form>
        </div>
    </c:if>

    <!-- ============================= -->
    <!-- 관리자 답변 댓글 영역 시작 -->
    <!-- ============================= -->
    <div class="comment-area">

        <h3>관리자 답변</h3>

        <c:choose>
            <c:when test="${empty commentList}">
                <div class="comment-empty">
                    등록된 관리자 답변이 없습니다.
                </div>
            </c:when>

            <c:otherwise>
                <c:forEach var="comment" items="${commentList}">
                    <div class="comment-box" id="commentBox_${comment.commentId}">

                        <div class="comment-header">
                            <strong>${comment.memberName}</strong>
                            <span>
                                <fmt:formatDate value="${comment.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                            </span>
                        </div>

                        <div class="comment-content" id="commentText_${comment.commentId}">
                            ${comment.commentContent}
                        </div>

                        <div class="comment-edit-box" id="commentEditBox_${comment.commentId}" style="display:none;">
                            <textarea id="commentEditContent_${comment.commentId}" rows="4">${comment.commentContent}</textarea>

                            <div class="comment-edit-btn-area">
                                <button type="button" onclick="modifyComment(${comment.commentId})">수정 완료</button>
                                <button type="button" class="btn-gray-small" onclick="cancelModifyComment(${comment.commentId})">취소</button>
                            </div>
                        </div>

                        <c:if test="${role eq 'ADMIN' or sessionScope.role eq 'ADMIN'}">
						    <div class="comment-btn-area">
						        <button type="button" onclick="showModifyComment(${comment.commentId})">수정</button>
						        <button type="button" class="btn-red-small" onclick="deleteComment(${comment.commentId})">삭제</button>
						    </div>
						</c:if>

                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>

        <c:if test="${role eq 'ADMIN' or sessionScope.role eq 'ADMIN'}">
		    <div class="comment-write-box">
		        <h4>관리자 답변 작성</h4>
		
		        <textarea id="commentContent"
		                  placeholder="답변 내용을 입력하세요"></textarea>
		
		        <button type="button" onclick="writeComment()">
		            답변 등록
		        </button>
		    </div>
		</c:if>

    </div>
    <!-- ============================= -->
    <!-- 관리자 답변 댓글 영역 끝 -->
    <!-- ============================= -->

</main>

<%@ include file="/WEB-INF/views/footer.jsp" %>

<script>
/**
 * 수정 폼 열기/닫기
 */
function showModifyForm() {
    var box = document.getElementById("modifyForm");
    box.style.display = box.style.display === "none" ? "block" : "none";
}

/**
 * 관리자 답변 등록
 */
 function writeComment() {
	    console.log("@# writeComment()");

	    var commentInput = $("#commentContent");

	    // textarea가 화면에 없을 때
	    if (commentInput.length === 0) {
	        alert("댓글 입력창을 찾을 수 없습니다. 관리자 권한 또는 JSP id를 확인하세요.");
	        console.log("@# commentContent textarea 없음");
	        return;
	    }

	    var commentContent = commentInput.val();

	    // 값이 undefined/null일 때 대비
	    if (commentContent == null) {
	        commentContent = "";
	    }

	    commentContent = commentContent.trim();

	    if (commentContent === "") {
	        alert("답변 내용을 입력하세요.");
	        commentInput.focus();
	        return;
	    }

	    $.ajax({
	        type: "post",
	        url: "${pageContext.request.contextPath}/comment_write",
	        data: {
	            boardNo: "${content_view.boardNo}",
	            commentContent: commentContent
	        },
	        success: function(result) {
	            console.log("@# comment_write result =>", result);

	            if (result === "success") {
	                alert("답변이 등록되었습니다.");
	                location.reload();

	            } else if (result === "login_required") {
	                alert("로그인이 필요합니다.");
	                location.href = "${pageContext.request.contextPath}/login_view";

	            } else if (result === "forbidden") {
	                alert("관리자만 답변을 작성할 수 있습니다.");

	            } else if (result === "empty") {
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

	            alert("서버 오류가 발생했습니다.");
	        }
	    });
	}

/**
 * 관리자 답변 수정 폼 열기
 */
function showModifyComment(commentId) {
    console.log("@# showModifyComment commentId =>", commentId);

    $("#commentText_" + commentId).hide();
    $("#commentEditBox_" + commentId).show();
}

/**
 * 관리자 답변 수정 취소
 */
function cancelModifyComment(commentId) {
    console.log("@# cancelModifyComment commentId =>", commentId);

    $("#commentEditBox_" + commentId).hide();
    $("#commentText_" + commentId).show();
}

/**
 * 관리자 답변 수정 처리
 */
function modifyComment(commentId) {
    const commentContent = $("#commentEditContent_" + commentId).val();

    console.log("@# modify commentId =>", commentId);
    console.log("@# modify commentContent =>", commentContent);

    if (commentContent.trim() === "") {
        alert("수정할 답변 내용을 입력하세요.");
        $("#commentEditContent_" + commentId).focus();
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

            if (result === "success") {
                alert("답변이 수정되었습니다.");
                location.reload();

            } else if (result === "login_required") {
                alert("로그인이 필요합니다.");
                location.href = "${pageContext.request.contextPath}/login_view";

            } else if (result === "not_admin") {
                alert("관리자만 답변을 수정할 수 있습니다.");

            } else if (result === "empty") {
                alert("수정할 답변 내용을 입력하세요.");

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

/**
 * 관리자 답변 삭제 처리
 */
function deleteComment(commentId) {
    console.log("@# delete commentId =>", commentId);

    if (!confirm("관리자 답변을 삭제하시겠습니까?")) {
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

            if (result === "success") {
                alert("답변이 삭제되었습니다.");
                location.reload();

            } else if (result === "login_required") {
                alert("로그인이 필요합니다.");
                location.href = "${pageContext.request.contextPath}/login_view";

            } else if (result === "not_admin") {
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