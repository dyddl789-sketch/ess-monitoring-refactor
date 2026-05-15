	window.onload = function() {
	    window.scrollTo(0, 0);
	};

    function selectType(type) {
        const tabs = document.querySelectorAll('.tab-btn');
        tabs.forEach(tab => tab.classList.remove('active'));

        if (type === 'PERSONAL') {
            tabs[0].classList.add('active');
        } else {
            tabs[1].classList.add('active');
        }

        document.getElementById('userType').value = type;
    }

    function execDaumPostcode() {
        new daum.Postcode({
            oncomplete: function(data) {
                var roadAddr = data.roadAddress;
                var jibunAddr = data.jibunAddress;

                document.getElementById('postcode').value = data.zonecode;

                if (roadAddr !== '') {
                    document.getElementById('roadAddress').value = roadAddr;
                } else {
                    document.getElementById('roadAddress').value = jibunAddr;
                }

                document.getElementById('detailAddress').focus();
            }
        }).open();
    }

    function makeFullAddress() {
        var postcode = document.getElementById('postcode').value;
        var roadAddress = document.getElementById('roadAddress').value;
        var detailAddress = document.getElementById('detailAddress').value;

        var fullAddress = "";

        if (postcode !== "") {
            fullAddress += "(" + postcode + ") ";
        }

        fullAddress += roadAddress;

        if (detailAddress !== "") {
            fullAddress += " " + detailAddress;
        }

        document.getElementById('address').value = fullAddress;
    }

    function joinCheck() {
        const memberPw = document.getElementById('memberPw').value;
        const memberPwCheck = document.getElementById('memberPwCheck').value;


        // HTML id와 동일하게 수정
        const agreeRequired = document.getElementById('agree_required').checked;
        const agreeMonitoring = document.getElementById('agree_monitoring').checked;


        if (memberPw.length < 8) {
            alert("비밀번호는 8자 이상 입력해주세요.");
            document.getElementById('memberPw').focus();
            return false;
        }

        if (memberPw !== memberPwCheck) {
            alert("비밀번호가 일치하지 않습니다.");
            document.getElementById('memberPwCheck').focus();
            return false;
        }

        if (!agreeRequired) {
            alert("서비스 이용약관 및 개인정보 처리방침에 동의해주세요.");
            return false;
        }

        if (!agreeMonitoring) {
            alert("ESS 모니터링 데이터 수집 및 분석 목적 확인이 필요합니다.");
            return false;
        }
		if (!makeFullPhone()) {
		    return false;
		}
		
		if (!makeFullEmail()) {
		    return false;
		}


        makeFullAddress();

        return true;
    }
    function makeFullPhone() {
    const phone1 = document.getElementById('phone1').value.trim();
    const phone2 = document.getElementById('phone2').value.trim();
    const phone3 = document.getElementById('phone3').value.trim();

    if (phone1 === "" && phone2 === "" && phone3 === "") {
        document.getElementById('phone').value = "";
        return true;
    }

    if (!/^[0-9]{3}$/.test(phone1)
            || !/^[0-9]{3,4}$/.test(phone2)
            || !/^[0-9]{4}$/.test(phone3)) {

        alert("연락처 형식을 확인해주세요.");
        document.getElementById('phone2').focus();
        return false;
    }

    document.getElementById('phone').value =
            phone1 + "-" + phone2 + "-" + phone3;

    return true;
}

function makeFullEmail() {
    const emailId = document.getElementById('emailId').value.trim();
    const emailDomain = document.getElementById('emailDomain').value.trim();

    if (emailId === "" && emailDomain === "") {
        document.getElementById('email').value = "";
        return true;
    }

    if (emailId === "" || emailDomain === "") {
        alert("이메일을 정확히 입력해주세요.");
        document.getElementById('emailId').focus();
        return false;
    }

    const fullEmail = (emailId + "@" + emailDomain).toLowerCase();

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(fullEmail)) {
        alert("이메일 형식을 확인해주세요.");
        document.getElementById('emailId').focus();
        return false;
    }

    document.getElementById('email').value = fullEmail;

    return true;
}

document.addEventListener('DOMContentLoaded', function() {
    const emailDomainSelect = document.getElementById('emailDomainSelect');
    const emailDomain = document.getElementById('emailDomain');

    emailDomainSelect.addEventListener('change', function() {
        emailDomain.value = this.value;

        if (this.value === "") {
            emailDomain.readOnly = false;
            emailDomain.focus();
        } else {
            emailDomain.readOnly = true;
        }
    });
});