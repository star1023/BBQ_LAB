google.charts.load('current', { packages: ['corechart'] });
google.charts.setOnLoadCallback(drawCharts);

function drawCharts() {
	drawPieChart();
	drawBarChartByDocType('PROD');
}

// 파이 차트: chartData1
function drawPieChart() {
	const chartContainer = document.getElementById('reportPieChart');
	if (!chartData1 || typeof chartData1 !== 'object') {
		chartContainer.innerHTML = "<div style='text-align:center; padding-top:100px;'>데이터가 존재하지 않습니다.</div>";
		return;
	}
	
	const data = new google.visualization.DataTable();
	data.addColumn('string', '보고서 구분');
	data.addColumn('number', '건수');

	const chartRows = [
		['제품개발', chartData1.PROD_CNT || 0],
		['메뉴개발', chartData1.MENU_CNT || 0],
		['상품설계', chartData1.DESIGN_CNT || 0],
		['관능&품질', chartData1.SENSE_QUALITY_CNT || 0],
		['출장계획', chartData1.PLAN_CNT || 0],
		['출장결과', chartData1.TRIP_CNT || 0],
		['시장조사', chartData1.RESEARCH_CNT || 0],
		['신제품품질', chartData1.RESULT_CNT || 0],
		['이화학검사', chartData1.CHEMICAL_CNT || 0],
		['표시사항기재', chartData1.PACKAGE_CNT || 0]
	];

	data.addRows(chartRows);

	const options = {
		pieHole: 0.4,
		chartArea: { width: '90%', height: '80%' },
		legend: { position: 'right', alignment: 'center' },
		height: 290
	};

	const chart = new google.visualization.PieChart(document.getElementById('reportPieChart'));
	chart.draw(data, options);
}

function drawBarChartByDocType(docTypeKey) {
	const statusMap = {
		TMP: '임시저장',
		REG: '등록',
		APPR: '결재중',
		COND_APPR: '부분승인',
		COMP: '완료',
		RET: '반려'
	};

	const statusColors = {
		TMP: '#adb5bd',
		REG: '#339af0',
		APPR: '#c24b4b',
		COND_APPR: '#ffb400',
		COMP: '#28a745',
		RET: '#6c757d'
	};
	
	const chartContainer = document.getElementById('reportBarChart');
	const raw = chartStatusData?.[docTypeKey];
	if (!raw || typeof raw !== 'object') {
		chartContainer.innerHTML = "<div style='text-align:center; padding-top:100px;'>데이터가 존재하지 않습니다.</div>";
		return;
	}

	const chartData = new google.visualization.DataTable();
	chartData.addColumn('string', '상태');
	chartData.addColumn('number', '건수');
	chartData.addColumn({ type: 'string', role: 'style' }); // ✅ 색상

	for (const key in statusMap) {
		const label = statusMap[key];
		const value = raw[key] || 0;
		const color = statusColors[key];
		chartData.addRow([label, value < 0 ? 0 : value, `color: ${color}`]);
	}

	const options = {
		chartArea: { width: '80%', height: '70%' },
		legend: { position: 'none' },
		hAxis: {  },
		vAxis: {
			minValue: 0,
			format: '0',
			viewWindow: { min: 0 }
		},
		height: 290
	};

	const chart = new google.visualization.ColumnChart(document.getElementById('reportBarChart'));
	chart.draw(chartData, options);
}
