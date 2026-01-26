let currentUserEmail = localStorage.getItem('currentUserEmail') || null;
let selectedTransactionDate = new Date().toISOString().split('T')[0];

const defaultStats = { income: 0, spending: 0, saving: 0, investments: 0 };
let stats = { ...defaultStats };
let transactionHistory = [];
let userProfile = { name: "New User", email: "", avatar: "prof.png" };

let currentCatName = "Food";
let currentCatIcon = "assets/Food.png";
let currentCatColor = "#D6BDD9";

const pocketColors = {
    income: '#DD6790', spending: '#CBA7D9', investments: '#CAD9A8', saving: '#D9AEA7'
};



function loadUserData(email) {
    currentUserEmail = email;
    localStorage.setItem('currentUserEmail', email);

    const savedStats = localStorage.getItem(`stats_${email}`);
    const savedHistory = localStorage.getItem(`history_${email}`);
    const savedProfile = localStorage.getItem(`profile_${email}`);

    stats = savedStats ? JSON.parse(savedStats) : { ...defaultStats };
    transactionHistory = savedHistory ? JSON.parse(savedHistory) : [];
    userProfile = savedProfile ? JSON.parse(savedProfile) : { 
        name: email.split('@')[0], email: email, avatar: "prof.png" 
    };

    updateProfileUI();
    updateDashboardUI();
    renderTransactionList();
    updateFinanceBars();
    updateInsights();
    
    if (document.getElementById('screen-analytics').style.display !== 'none') {
        drawPocketChart();
        updateSyncStats();
        drawWeeklyAnalytics();
    }
}

function saveToLocalStorage() {
    if (!currentUserEmail) return;
    localStorage.setItem(`stats_${currentUserEmail}`, JSON.stringify(stats));
    localStorage.setItem(`history_${currentUserEmail}`, JSON.stringify(transactionHistory));
    localStorage.setItem(`profile_${currentUserEmail}`, JSON.stringify(userProfile));
}



function updateCurrentDate() {
    const el = document.querySelector('.date-value');
    if (el) {
        const d = new Date();
        el.innerText = `${String(d.getDate()).padStart(2, '0')}.${String(d.getMonth()+1).padStart(2, '0')}.${d.getFullYear()}`;
    }
}

function updateProfileUI() {
    document.querySelectorAll('.profile-name').forEach(el => el.innerText = userProfile.name);
    document.querySelectorAll('.avatar-img, #profile-preview').forEach(img => img.src = userProfile.avatar);
    
    const nameInput = document.querySelector('#screen-profile .form-group input[type="text"]');
    const emailInput = document.querySelector('#screen-profile .form-group input[type="email"]');
    if (nameInput) nameInput.value = userProfile.name;
    if (emailInput) emailInput.value = userProfile.email;
}

function updateDashboardUI() {
    const ids = {
        'stat-income': stats.income, 
        'stat-spending': stats.spending, 
        'stat-saving': stats.saving, 
        'stat-investments': stats.investments
    };
    for (let id in ids) {
        const el = document.getElementById(id);
        if (el) el.innerText = `$ ${ids[id].toLocaleString()}`;
    }
}


function openCategoryModal(catName, catColor) {
    const modal = document.getElementById('modal-overlay');
    const title = document.getElementById('modal-category-title');
    const totalEl = document.getElementById('modal-category-total');
    const listContainer = document.getElementById('category-transactions-list');

    if (!modal || !listContainer) return;

    title.innerText = catName;
    
    
    const filtered = transactionHistory.filter(t => t.name === catName);
    const total = filtered.reduce((sum, t) => sum + Number(t.amount), 0);
    totalEl.innerText = `$ ${total.toLocaleString()}`;

    listContainer.innerHTML = '';
    if (filtered.length === 0) {
        listContainer.innerHTML = '<p style="text-align:center; color: #999; margin-top: 20px;">No transactions yet</p>';
    } else {
        filtered.forEach(t => {
            const div = document.createElement('div');
            div.className = "trans-item";
            div.innerHTML = `
                <div class="trans-info">
                    <div class="trans-icon-bg" style="background-color: ${t.color};"><img src="${t.icon}"></div>
                    <div class="trans-text">
                        <p class="trans-name">${t.method}</p>
                        <p class="trans-sub">${t.date}</p>
                    </div>
                </div>
                <p class="trans-value">${t.isIncome ? '+' : '-'}${t.amount} $</p>`;
            listContainer.appendChild(div);
        });
    }
    modal.classList.add('active');
}




function addNewTransaction() {
    const amountInput = document.getElementById('trans-amount');
    const amount = parseFloat(amountInput.value.replace('$', '').trim());
    if (isNaN(amount) || amount <= 0) return alert("Enter amount");

    const datePicker = document.getElementById('transaction-date-input');
    const rawDate = datePicker.value || new Date().toISOString().split('T')[0];
    const d = new Date(rawDate);
    const formattedDate = `${String(d.getDate()).padStart(2, '0')}.${String(d.getMonth()+1).padStart(2, '0')}.${d.getFullYear()}`;

    const isSalary = currentCatName === 'Salary';
    if (isSalary) stats.income += amount;
    else if (currentCatName === 'Investments') stats.investments += amount;
    else if (currentCatName === 'Saving') stats.saving += amount;
    else stats.spending += amount;

    transactionHistory.unshift({
        id: Date.now(),
        amount, 
        name: currentCatName, 
        icon: currentCatIcon,
        color: currentCatColor, 
        method: document.querySelector('input[name="pay-method"]:checked')?.value || "Cash", 
        date: formattedDate,
        rawDate: rawDate,
        isIncome: isSalary
    });

    

    transactionHistory.sort((a, b) => new Date(b.rawDate) - new Date(a.rawDate));

    saveToLocalStorage();
    updateDashboardUI();
    renderTransactionList();
    updateFinanceBars();
    updateInsights();
    
    if (document.getElementById('screen-analytics').style.display !== 'none') {
        drawWeeklyAnalytics();
        drawPocketChart();
        updateSyncStats();
    }
    amountInput.value = '';
}

function deleteTransaction(id) {
    const index = transactionHistory.findIndex(t => t.id === id);
    if (index === -1) return;
    const t = transactionHistory[index];

    if (t.isIncome) stats.income -= t.amount;
    else if (t.name === 'Investments') stats.investments -= t.amount;
    else if (t.name === 'Saving') stats.saving -= t.amount;
    else stats.spending -= t.amount;

    transactionHistory.splice(index, 1);
    saveToLocalStorage();
    updateDashboardUI();
    renderTransactionList();
    updateFinanceBars();
    updateInsights();
    
    if (document.getElementById('screen-analytics').style.display !== 'none') {
        drawPocketChart();
        updateSyncStats();
        drawWeeklyAnalytics();
    }
}

function renderTransactionList() {
    const wrapper = document.getElementById('dashboard-transactions-wrapper');
    if (!wrapper) return;

    wrapper.innerHTML = '';
    transactionHistory.forEach(t => {
        const div = document.createElement('div');
        div.className = "trans-item";
        div.onclick = () => { if(confirm(`Delete "${t.name}"?`)) deleteTransaction(t.id); };
        div.innerHTML = `
            <div class="trans-info">
                <div class="trans-icon-bg" style="background-color: ${t.color};"><img src="${t.icon}"></div>
                <div class="trans-text"><p class="trans-name">${t.name}</p><p class="trans-sub">${t.method}</p></div>
            </div>
            <div style="text-align: right;">
                <p class="trans-date" style="font-size: 11px; color: #999;">${t.date}</p>
                <p class="trans-value">${t.isIncome ? '+' : '-'}${t.amount} $</p>
            </div>`;
        wrapper.appendChild(div);
    });
}




function drawWeeklyAnalytics() {
    const svg = document.getElementById('weeklySvgGraph');
    const linePath = document.getElementById('graphLine');
    const areaPath = document.getElementById('graphArea');
    if (!svg || !linePath) return;

    const width = svg.clientWidth;
    const height = svg.clientHeight;

    let targetDate = new Date(selectedTransactionDate);
    let dayOfWeek = targetDate.getDay(); 
    let diffToMonday = targetDate.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1);
    let startOfWeek = new Date(targetDate.setDate(diffToMonday));

    let weeklyData = [];
    let labelsX = [];

    for (let i = 0; i < 7; i++) {
        let d = new Date(startOfWeek);
        d.setDate(startOfWeek.getDate() + i);
        const dateStr = `${String(d.getDate()).padStart(2, '0')}.${String(d.getMonth() + 1).padStart(2, '0')}.${d.getFullYear()}`;
        const dailySum = transactionHistory
            .filter(t => t.date === dateStr && !t.isIncome)
            .reduce((sum, t) => sum + Number(t.amount), 0);
        weeklyData.push(dailySum);
        labelsX.push(d.toLocaleDateString('en-US', { weekday: 'short' }));
    }

    const xAxisDays = document.getElementById('x-axis-days');
    if (xAxisDays) xAxisDays.innerHTML = labelsX.map(d => `<span>${d}</span>`).join('');
    
    let maxVal = Math.max(...weeklyData, 100);
    const yAxisLabels = document.getElementById('y-axis-labels');
    if (yAxisLabels) yAxisLabels.innerHTML = `<span>$${maxVal}</span><span>$${Math.floor(maxVal/2)}</span><span>0</span>`;

    const points = weeklyData.map((val, i) => ({
        x: (i * (width / (weeklyData.length - 1))),
        y: height - (val / maxVal * height)
    }));

    let dPath = `M ${points[0].x} ${points[0].y}`;
    for (let i = 0; i < points.length - 1; i++) {
        const p1 = points[i];
        const p2 = points[i + 1];
        const cpX = (p1.x + p2.x) / 2;
        dPath += ` Q ${p1.x} ${p1.y} ${cpX} ${(p1.y + p2.y) / 2}`;
    }
    dPath += ` L ${points[points.length-1].x} ${points[points.length-1].y}`;

    linePath.setAttribute('d', dPath);
    if (areaPath) areaPath.setAttribute('d', dPath + ` L ${width} ${height} L 0 ${height} Z`);
}

function drawPocketChart() {
    const canvas = document.getElementById('pocketCanvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    
    const data = [
        { label: 'Income', value: stats.income, color: pocketColors.income },
        { label: 'Spent', value: stats.spending, color: pocketColors.spending },
        { label: 'Investments', value: stats.investments, color: pocketColors.investments },
        { label: 'Saving', value: stats.saving, color: pocketColors.saving }
    ];

    const total = data.reduce((sum, item) => sum + item.value, 0);
    const totalEl = document.getElementById('pocket-total-sum');
    if (totalEl) totalEl.innerText = `$ ${total.toLocaleString()}`;

    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;
    const radius = 80;
    const thickness = 25;
    let startAngle = -Math.PI / 2;

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    if (total === 0) {
        ctx.beginPath(); ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
        ctx.strokeStyle = '#E0E0E0'; ctx.lineWidth = thickness; ctx.stroke();
        return;
    }

    const legend = document.getElementById('pocket-legend');
    if (legend) legend.innerHTML = '';

    data.forEach(item => {
        const sliceAngle = (item.value / total) * 2 * Math.PI;
        if (item.value > 0) {
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, startAngle, startAngle + sliceAngle);
            ctx.strokeStyle = item.color; ctx.lineWidth = thickness; ctx.lineCap = 'round'; ctx.stroke();
            startAngle += sliceAngle;
        }
        if (legend) {
            legend.innerHTML += `<div class="legend-item"><div class="legend-dot" style="background:${item.color}"></div><div class="legend-info"><p>${item.label}</p><h4>$ ${item.value.toLocaleString()}</h4></div></div>`;
        }
    });
}

function updateSyncStats() {
    const setTxt = (id, val) => { const el = document.getElementById(id); if(el) el.innerText = val; };

    if (transactionHistory.length === 0) {
        ['stat-s', 'stat-fc', 'stat-med', 'stat-mpm', 'stat-msm', 'stat-avg-income', 'stat-avg-outcome'].forEach(id => setTxt(id, "-"));
        return;
    }

    const expenses = transactionHistory.filter(t => !t.isIncome);
    const incomes = transactionHistory.filter(t => t.isIncome);

    // 1. Total Spending
    const totalSpending = expenses.reduce((sum, t) => sum + Number(t.amount), 0);
    setTxt('stat-s', `$ ${totalSpending.toLocaleString()}`);

    // 2. Favorite Category (найчастіша)
    if (expenses.length > 0) {
        const catCount = {};
        expenses.forEach(t => catCount[t.name] = (catCount[t.name] || 0) + 1);
        const favorite = Object.keys(catCount).reduce((a, b) => catCount[a] > catCount[b] ? a : b);
        setTxt('stat-fc', favorite);
    }

    // 3. Most Expensive Day (День з найбільшими витратами)
    if (expenses.length > 0) {
        const daySpending = {};
        expenses.forEach(t => daySpending[t.date] = (daySpending[t.date] || 0) + Number(t.amount));
        const expensiveDay = Object.keys(daySpending).reduce((a, b) => daySpending[a] > daySpending[b] ? a : b);
        setTxt('stat-med', expensiveDay);
    }

    // 4. Months logic (Profitable / Spending Month)
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const mProfit = {}; // Чистий прибуток (Income - Spending)
    const mSpent = {};  // Тільки витрати

    transactionHistory.forEach(t => {
        const monthIndex = parseInt(t.date.split('.')[1]) - 1;
        const m = monthNames[monthIndex];
        if (t.isIncome) {
            mProfit[m] = (mProfit[m] || 0) + Number(t.amount);
        } else {
            mProfit[m] = (mProfit[m] || 0) - Number(t.amount);
            mSpent[m] = (mSpent[m] || 0) + Number(t.amount);
        }
    });

    // Most Profitable Month
    const bestMonth = Object.keys(mProfit).reduce((a, b) => mProfit[a] > mProfit[b] ? a : b, "-");
    setTxt('stat-mpm', bestMonth);

    // Most Spending Month
    const worstMonth = Object.keys(mSpent).reduce((a, b) => mSpent[a] > mSpent[b] ? a : b, "-");
    setTxt('stat-msm', worstMonth);

    // 5. Averages (Income per Year / Outcome per Month)
    const uniqueYears = new Set(transactionHistory.map(t => t.date.split('.')[2])).size || 1;
    const uniqueMonths = new Set(transactionHistory.map(t => t.date.substring(3))).size || 1;
    
    const totalIncome = incomes.reduce((sum, t) => sum + Number(t.amount), 0);
    
    setTxt('stat-avg-income', `$ ${Math.round(totalIncome / uniqueYears).toLocaleString()}`);
    setTxt('stat-avg-outcome', `$ ${Math.round(totalSpending / uniqueMonths).toLocaleString()}`);
}

function updateFinanceBars() {
    const monthlySpending = new Array(12).fill(0);
    transactionHistory.forEach(t => {
        if (!t.isIncome) {
            const mIdx = parseInt(t.date.split('.')[1]) - 1; 
            if (mIdx >= 0 && mIdx <= 11) monthlySpending[mIdx] += t.amount;
        }
    });
    const maxS = Math.max(...monthlySpending, 100);
    monthlySpending.forEach((amt, i) => {
        const bar = document.getElementById(`bar-${i}`);
        if (bar) bar.style.height = `${(amt / maxS) * 100}%`;
    });
}

function updateInsights() {
    const healthValue = document.getElementById('health-value');
    if (!healthValue) return;
    const ratio = stats.income > 0 ? (stats.spending / stats.income) : 0;
    
    if (ratio > 0.8) {
        healthValue.innerText = "Bad"; healthValue.style.color = "#DD6790"; updateDots(1);
    } else if (ratio > 0.5) {
        healthValue.innerText = "Fair"; healthValue.style.color = "#E3E1C5"; updateDots(3);
    } else {
        healthValue.innerText = "Excellent"; healthValue.style.color = "#B5DBC5"; updateDots(5);
    }
}

function updateDots(activeCount) {
    const dots = document.querySelectorAll('.health-dots .dot');
    dots.forEach((dot, index) => dot.classList.toggle('active', index < activeCount));
}




window.switchTab = (tabName, event) => {
    document.querySelectorAll('.screen').forEach(s => s.style.display = 'none');
    document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));
    
    const target = document.getElementById('screen-' + tabName);
    if (target) target.style.display = (tabName === 'dashboard' || tabName === 'analytics') ? 'flex' : 'block';
    
    const titleEl = document.getElementById('current-title');
    if (titleEl) titleEl.innerText = tabName.charAt(0).toUpperCase() + tabName.slice(1);

    if (event) event.currentTarget.classList.add('active');

    if (tabName === 'analytics') {
        setTimeout(() => { drawPocketChart(); drawWeeklyAnalytics(); updateSyncStats(); }, 50);
    }
};

document.addEventListener('DOMContentLoaded', () => {
    updateCurrentDate();
    
    // --- Upload Image logic ---
    const fileInput = document.getElementById('avatar-upload-input');
    const uploadBtn = document.getElementById('trigger-upload');

    uploadBtn?.addEventListener('click', (e) => {
        e.preventDefault();
        fileInput.click();
    });

    fileInput?.addEventListener('change', function() {
        const file = this.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                userProfile.avatar = e.target.result;
                updateProfileUI();
                saveToLocalStorage();
            };
            reader.readAsDataURL(file);
        }
    });
    // --- End Upload Image logic ---

    document.querySelectorAll('.category-item').forEach(item => {
        item.addEventListener('click', () => {
            const name = item.querySelector('span').innerText;
            const color = item.querySelector('.cat-icon').style.backgroundColor;
            openCategoryModal(name, color);
        });
    });

    document.getElementById('close-modal')?.addEventListener('click', () => {
        document.getElementById('modal-overlay').classList.remove('active');
    });

    document.getElementById('toggle-auth')?.addEventListener('click', (e) => { e.preventDefault(); toggleAuthMode(); });

    document.getElementById('auth-form')?.addEventListener('submit', (e) => {
        e.preventDefault();
        const email = document.getElementById('auth-email').value.trim().toLowerCase();
        const name = document.getElementById('auth-name')?.value.trim();
        const isReg = document.getElementById('submit-btn').innerText === 'Sign Up';

        if (isReg) {
            if (localStorage.getItem(`profile_${email}`)) return alert("User exists!");
            localStorage.setItem(`profile_${email}`, JSON.stringify({ name: name || email.split('@')[0], email, avatar: "prof.png" }));
            localStorage.setItem(`stats_${email}`, JSON.stringify(defaultStats));
            localStorage.setItem(`history_${email}`, JSON.stringify([]));
        } else {
            if (!localStorage.getItem(`profile_${email}`)) return alert("User not found!");
        }
        loadUserData(email);
        document.getElementById('auth-overlay').style.display = 'none';
    });

    

    document.getElementById('category-selector')?.addEventListener('click', (e) => {
        e.stopPropagation();
        document.querySelector('.select-items').classList.toggle('select-hide');
    });

    window.selectCat = (name, icon, color) => {
        currentCatName = name; currentCatIcon = icon; currentCatColor = color;
        document.getElementById('selected-text').innerText = name;
        document.getElementById('selected-icon').src = icon;
        document.querySelector('.select-items').classList.add('select-hide');
    };

    if (currentUserEmail) loadUserData(currentUserEmail);
});

function toggleAuthMode() {
    const btn = document.getElementById('submit-btn');
    const isLogin = btn.innerText === 'Log In';
    document.getElementById('auth-title').innerText = isLogin ? 'Create Account' : 'Welcome Back';
    document.getElementById('name-group').style.display = isLogin ? 'block' : 'none';
    btn.innerText = isLogin ? 'Sign Up' : 'Log In';
    document.getElementById('toggle-auth').innerText = isLogin ? 'Log In' : 'Sign Up';
}



function saveProfileChanges(e) {
    if (e) e.preventDefault(); 


    const nameInput = document.querySelector('#screen-profile .form-group input[type="text"]');
    const newName = nameInput ? nameInput.value.trim() : "";

    if (newName) {
        

        userProfile.name = newName;
        
        

        saveToLocalStorage();
        
        

        updateProfileUI();
        
        alert("Profile updated successfully!");
    }
}



document.querySelector('#screen-profile .btn-save')?.addEventListener('click', saveProfileChanges);