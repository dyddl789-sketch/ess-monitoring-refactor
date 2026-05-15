function selectType(type) {

    const tabs = document.querySelectorAll('.tab-btn');

    tabs.forEach(tab => tab.classList.remove('active'));

    document.getElementById('userType').value = type;

    if (type === 'PERSONAL') {

        tabs[0].classList.add('active');

        console.log("개인용 로그인 모드");

    } else {

        tabs[1].classList.add('active');

        console.log("기업용 로그인 모드");
    }
}