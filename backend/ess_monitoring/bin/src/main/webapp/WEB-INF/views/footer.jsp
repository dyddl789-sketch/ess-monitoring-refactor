<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
.site-footer {
    background-color: #2c3e50;
    color: white;
    padding: 40px 0;
    margin-top: 60px;
}
.footer-content {
    display: flex;
    justify-content: space-between;
    flex-wrap: wrap;
}
.footer-logo {
    margin-bottom:10px;
}
.footer-info p {
    color:#bdc3c7;
}
.footer-info address {
    font-style: normal;
    line-height: 1.6;
}
.copyright {
    margin-top:15px;
    font-size:0.85rem;
    color:#95a5a6;
}
.footer-links ul {
    list-style:none;
    padding:0;
    line-height:2;
}
.footer-links a {
    color:#bdc3c7;
    text-decoration:none;
}
.sns-icons {
    display:flex;
    gap:15px;
    color:#bdc3c7;
}
</style>

<footer class="site-footer">
    <div class="container footer-content">
        <div class="footer-info">
            <h2 class="footer-logo">ESS-M.S</h2>
            <p>스마트 에너지 모니터링 시스템 전문 기업</p>
            <address>
                부산광역시 범내골 KH 학원 <br>
                대표전화: 051-123-4567 | 이메일: info@ess-ms.com
            </address>
            <p class="copyright">&copy; 2026 ESS-Monitoring System. All Rights Reserved.</p>
        </div>

        <div class="footer-links">
            <h4>Quick Links</h4>
            <ul>
                <li><a href="${pageContext.request.contextPath}/main">홈</a></li>
                <li><a href="${pageContext.request.contextPath}/main#service">서비스 소개</a></li>
                <li><a href="${pageContext.request.contextPath}/board_list">문의게시판</a></li>
            </ul>
        </div>

        <div class="footer-sns">
            <h4>Follow Us</h4>
            <div class="sns-icons">
                <span>Blog</span>
                <span>LinkedIn</span>
                <span>Youtube</span>
            </div>
        </div>
    </div>
</footer>