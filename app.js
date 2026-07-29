// PC PowerSaver Pro Web Dashboard Logic
document.addEventListener('DOMContentLoaded', () => {
    // 1. Navigation Switching
    const navItems = document.querySelectorAll('.nav-item');
    const tabContents = document.querySelectorAll('.tab-content');
    const pageTitle = document.getElementById('page-title');

    const tabTitles = {
        dashboard: '스마트 전원 대시보드',
        timer: '타이머 절전 컨트롤러',
        calculator: '소비전력 & 전기요금 절감 계산기',
        commands: 'Windows 전원 명령어 매니저'
    };

    navItems.forEach(item => {
        item.addEventListener('click', () => {
            const targetTab = item.getAttribute('data-tab');

            navItems.forEach(n => n.classList.remove('active'));
            tabContents.forEach(t => t.classList.remove('active'));

            item.classList.add('active');
            document.getElementById(`tab-${targetTab}`).classList.add('active');
            pageTitle.textContent = tabTitles[targetTab] || 'PowerSaver';
        });
    });

    // 2. Toast Notification Helper
    const toast = document.getElementById('toast');
    function showToast(message) {
        toast.textContent = message;
        toast.classList.add('show');
        setTimeout(() => {
            toast.classList.remove('show');
        }, 3000);
    }

    // 3. Caffeine Mode Toggle
    const btnCaffeine = document.getElementById('btn-caffeine-web');
    const caffeineText = document.getElementById('caffeine-text');
    let isCaffeineOn = false;

    btnCaffeine.addEventListener('click', () => {
        isCaffeineOn = !isCaffeineOn;
        if (isCaffeineOn) {
            btnCaffeine.classList.remove('btn-outline');
            btnCaffeine.classList.add('btn-primary');
            caffeineText.textContent = '카페인 모드: ON ☕';
            showToast('카페인 모드가 활성화되었습니다. (화면/시스템 절전 방지)');
        } else {
            btnCaffeine.classList.remove('btn-primary');
            btnCaffeine.classList.add('btn-outline');
            caffeineText.textContent = '카페인 모드: OFF';
            showToast('카페인 모드가 해제되었습니다.');
        }
    });

    // Launch GUI Guide Button
    document.getElementById('btn-launch-gui').addEventListener('click', () => {
        showToast('Run_PowerSaver.bat 배치 파일을 실행하시면 native Windows GUI 창이 표시됩니다!');
    });

    // 4. Quick Actions Simulation
    document.getElementById('q-screen-off').addEventListener('click', () => {
        showToast('🖥️ 모니터 전원 차단 신호를 송신했습니다.');
    });

    document.getElementById('q-sleep').addEventListener('click', () => {
        showToast('🌙 시스템 절전 모드(SetSuspendState) 신호를 송신했습니다.');
    });

    document.getElementById('q-hibernate').addEventListener('click', () => {
        showToast('💤 최대 절전 모드(Hibernate)를 준비합니다.');
    });

    document.getElementById('q-shutdown').addEventListener('click', () => {
        showToast('🔌 안전한 완전 종료(Shutdown) 카운트다운을 준비합니다.');
    });

    // 5. Timer Controller Engine
    const timerRing = document.getElementById('timer-ring');
    const timerClock = document.getElementById('timer-clock');
    const timerActionLabel = document.getElementById('timer-action-label');
    const sliderMins = document.getElementById('web-timer-slider');
    const actionSelect = document.getElementById('web-action-select');
    const btnStart = document.getElementById('btn-start-web-timer');
    const btnStop = document.getElementById('btn-stop-web-timer');
    const presetBtns = document.querySelectorAll('.btn-preset');

    const ringCircumference = 565; // 2 * PI * r (r=90)
    let webTimerInterval = null;
    let totalSeconds = 1800;
    let remainingSeconds = 1800;

    function updateClockDisplay(sec) {
        const m = Math.floor(sec / 60);
        const s = sec % 60;
        timerClock.textContent = `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
        
        const offset = ringCircumference - (sec / totalSeconds) * ringCircumference;
        timerRing.style.strokeDashoffset = offset;
    }

    sliderMins.addEventListener('input', (e) => {
        if (!webTimerInterval) {
            const mins = parseInt(e.target.value);
            totalSeconds = mins * 60;
            remainingSeconds = totalSeconds;
            updateClockDisplay(remainingSeconds);
            
            presetBtns.forEach(b => {
                b.classList.toggle('active', parseInt(b.getAttribute('data-mins')) === mins);
            });
        }
    });

    presetBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            if (!webTimerInterval) {
                const mins = parseInt(btn.getAttribute('data-mins'));
                sliderMins.value = mins;
                totalSeconds = mins * 60;
                remainingSeconds = totalSeconds;
                updateClockDisplay(remainingSeconds);

                presetBtns.forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
            }
        });
    });

    btnStart.addEventListener('click', () => {
        if (webTimerInterval) return;

        const actionText = actionSelect.options[actionSelect.selectedIndex].text;
        timerActionLabel.textContent = `진행 중: ${actionText}`;

        btnStart.disabled = true;
        btnStop.disabled = false;
        sliderMins.disabled = true;

        showToast(`⏱️ ${Math.floor(remainingSeconds/60)}분 카운트다운 타이머가 시작되었습니다.`);

        webTimerInterval = setInterval(() => {
            remainingSeconds--;
            updateClockDisplay(remainingSeconds);

            if (remainingSeconds <= 0) {
                clearInterval(webTimerInterval);
                webTimerInterval = null;
                timerActionLabel.textContent = '완료! 동작 실행 됨';
                btnStart.disabled = false;
                btnStop.disabled = true;
                sliderMins.disabled = false;
                showToast(`🎉 타이머가 완료되어 [${actionText}] 동작이 실행되었습니다!`);
            }
        }, 1000);
    });

    btnStop.addEventListener('click', () => {
        if (webTimerInterval) {
            clearInterval(webTimerInterval);
            webTimerInterval = null;
        }
        remainingSeconds = totalSeconds;
        updateClockDisplay(remainingSeconds);
        timerActionLabel.textContent = '절전 모드 대기 중';

        btnStart.disabled = false;
        btnStop.disabled = true;
        sliderMins.disabled = false;
        showToast('타이머가 취소되었습니다.');
    });

    // 6. Energy & Cost Calculator Logic
    const inputWatt = document.getElementById('calc-watt');
    const inputHours = document.getElementById('calc-hours');
    const inputRate = document.getElementById('calc-rate');

    const resDailyKwh = document.getElementById('res-daily-kwh');
    const resMonthlyKwh = document.getElementById('res-monthly-kwh');
    const resMonthlyCost = document.getElementById('res-monthly-cost');
    const resYearlyCost = document.getElementById('res-yearly-cost');

    function calculateSavings() {
        const watt = parseFloat(inputWatt.value) || 0;
        const hours = parseFloat(inputHours.value) || 0;
        const rate = parseFloat(inputRate.value) || 0;

        const dailyKwh = (watt * hours) / 1000;
        const monthlyKwh = dailyKwh * 30;
        const monthlyCost = monthlyKwh * rate;
        const yearlyCost = monthlyCost * 12;

        resDailyKwh.textContent = `${dailyKwh.toFixed(2)} kWh`;
        resMonthlyKwh.textContent = `${monthlyKwh.toFixed(1)} kWh`;
        resMonthlyCost.textContent = `₩ ${Math.round(monthlyCost).toLocaleString()} 원`;
        resYearlyCost.textContent = `₩ ${Math.round(yearlyCost).toLocaleString()} 원`;
    }

    [inputWatt, inputHours, inputRate].forEach(input => {
        input.addEventListener('input', calculateSavings);
    });
    calculateSavings();

    // 7. Clipboard Copy Helper
    document.querySelectorAll('.btn-copy').forEach(btn => {
        btn.addEventListener('click', () => {
            const cmd = btn.getAttribute('data-copy');
            navigator.clipboard.writeText(cmd).then(() => {
                showToast('클립보드에 명령어가 복사되었습니다!');
            }).catch(() => {
                showToast('복사에 실패했습니다.');
            });
        });
    });
});
