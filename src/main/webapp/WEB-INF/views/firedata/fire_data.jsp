<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>   
<c:set var="CP"  value="${pageContext.request.contextPath}"  />
<!DOCTYPE html>
<html lang="kor">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta charset="UTF-8">
<head>
<!-- 파비콘 추가 -->
<link rel="icon" type="image/x-icon" href="${CP}/resources/img/favicon.ico">
<link rel="stylesheet" href="${CP}/resources/css/bootstrap.css">
<!-- bootstrap icon -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<!-- bootstrap icon -->
<link rel="stylesheet" href="${CP}/resources/css/basic_style.css">
<link rel="stylesheet" href="${CP}/resources/css/fRstyle.css">
<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
<script src="${CP}/resources/js/common.js"></script> 
<script src="https://code.highcharts.com/highcharts.js"></script>

<title>ANPA</title>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // .nav 클래스의 첫 번째 .nav-item의 자식 .nav-link를 선택합니다
    const firstNavLink = document.querySelector('.nav .nav-item:first-child .nav-link');

    // 선택한 요소에 "active" 클래스를 추가합니다
    firstNavLink.classList.add('active');
    
    //화재 요인 버튼
    const factorBtn = document.querySelector('#factor');
    //화재 장소 버튼
    const locationBtn = document.querySelector('#location');
    //대분류
    const bigList = document.querySelector('#bigList');
    //소분류
    const midList = document.querySelector('#midList');
    //날짜시작
    const fRdateStart = document.querySelector('#fRdateStart');
    //날짜끝
    const fRdateEnd = document.querySelector('#fRdateEnd');
    //조회버튼
    const doRetrieveBtn = document.querySelector('#doRetrieve');
    //지도 객체
    const lands = document.querySelectorAll('.land');
    //시도,시군구
    const sido = document.querySelector('#sido');
    const sigungo = document.querySelector('#sigungo');
    //초기화
    const resycleBtn = document.querySelector('#resycle');
    
    let div = '';
    let selectedText = '';
    let workDiv = '';
    //검색조건
    const searchConditions = document.querySelector('#searchConditions');
    //CSV 파일 다운로드
    const CSVBtn = document.querySelector('#CSV');
    
    // 시작, 끝 날짜 디폴트 값
    let now = new Date();
	let year = now.getFullYear();
	let month = String(now.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 +1
	let lastmonth = String(now.getMonth()).padStart(2, '0'); 
	let day = String(now.getDate()).padStart(2, '0'); // 날짜는 1부터 시작
	
    let currentDate = year+'-'+month+'-'+day;
	let lastMonthDate = year+'-'+lastmonth+'-'+day;
    fRdateEnd.value = currentDate;
    fRdateStart.value = lastMonthDate;
    
    //검색 조건들
    let bigListText = '';
    let midListText = '';
    let sidoText = '';
    let sigungoText = '';
    let searchDiv = '';
    
    //이벤트
    
    //초기화
    resycleBtn.addEventListener("click",function(event){
    	event.stopPropagation();
    	$('g').addClass('d-none');
    	$('#CSV').addClass('d-none');
    	bigList.value = '';
    	midList.value = '';
    	searchConditions.textContent = '';
    	fRdateEnd.value = currentDate;
        fRdateStart.value = lastMonthDate;
        fireCnt.innerHTML = '';
        fireAmount.innerHTML = '';
        result.innerHTML = '';
        $('#thead').html('');
        $('#tbody').html('');
        sido.value = '';
        sigungo.value = '';
    });
    
    //CSV파일 다운로드
    CSVBtn.addEventListener("click",function(event){
    	event.stopPropagation();
    	getCSV('fireData'+div+'.csv');
    	
    });
    
    function downloadCSV(csv, filename) {
        let csvFile;
        let downloadLink;

        // CSV 파일을 위한 Blob 만들기
        csvFile = new Blob([csv], {type: "text/csv"});

        // Download link를 위한 a 엘리먼스 생성
        downloadLink = document.createElement("a");

        // 다운받을 csv 파일 이름 지정하기
        downloadLink.download = filename;

        // 위에서 만든 blob과 링크를 연결
        downloadLink.href = window.URL.createObjectURL(csvFile);

        // 링크가 눈에 보일 필요는 없으니 숨겨줍시다.
        downloadLink.style.display = "none";

        // HTML 가장 아래 부분에 링크를 붙여줍시다.
        document.body.appendChild(downloadLink);

        // 클릭 이벤트를 발생시켜 실제로 브라우저가 '다운로드'하도록 만들어줍시다.
        downloadLink.click();
    }

    function getCSV(filename) {
    	const csv = [];
        const rows = document.querySelectorAll("#table tr");
        const numCols = Array.from(rows[0].querySelectorAll("td, th")).length;
        
        rows.forEach(function(row, rowIndex){
            const rowData = [];
            const cols = row.querySelectorAll("td, th");
            
            let colIndex = 0;

            cols.forEach(function(cell){
                const colspan = parseInt(cell.getAttribute('colspan') || 1, 10);
                const rowspan = parseInt(cell.getAttribute('rowspan') || 1, 10);

                // colspan을 위한 빈 셀 추가
                for (let i = 0; i < colspan; i++) {
                    if (colIndex < rowData.length) {
                        rowData[colIndex] = escapeCSVValue(cell.innerText);
                    } else {
                        rowData.push(escapeCSVValue(cell.innerText));
                    }
                    colIndex++;
                }

                // 필요 시, colspan에 대한 빈 셀 추가
                if (colIndex < numCols) {
                    for (let i = colIndex; i < numCols; i++) {
                        if (rowData[i] === undefined) {
                            rowData[i] = ''; // colspan을 위한 빈 문자열로 채우기
                        }
                    }
                }
            });

            csv.push(rowData.join(","));
        });

        // Download CSV
        downloadCSV(csv.join("\n"), filename);
    }
    
    function escapeCSVValue(value) {
        // 큰따옴표와 줄바꿈을 이스케이프하고 큰따옴표로 감싸기
        if (value.includes('"') || value.includes(',') || value.includes('\n')) {
            value = '"' + value.replace(/"/g, '""') + '"';
        }
        return value;
    }
    
    //지도 선택시 시도 선택
    lands.forEach(function(land){
    	land.addEventListener("click",function(event){
    		event.stopPropagation();
    		//console.log('click'+event.target);
    		
    		let title = event.target.getAttribute('title');
    		//console.log('title:'+title);
    		
    		sido.value = title;
    		
    		let searchDiv = '20';
            div = 'city';
            categoryMidList(searchDiv,div,title,sigungo);
            
            doData();
    	});
    	
    });
	    
    
    //시도 선택시
    sido.addEventListener("change",function(event){
    	event.stopPropagation();
        let searchDiv = '20';
        let searchWord = sido.value;
        div = 'city';
        
        if(sido.value = '') sigungo.value = '';
        
        categoryMidList(searchDiv,div,searchWord,sigungo);
        
        for (let i = 0; i < sido.options.length; i++) {
            if (sido.options[i].value === searchWord) {
            	sido.selectedIndex = i;
                break;
            }
        }
        doData();
    });
    
    //시군구 선택시
    sigungo.addEventListener("change",function(event){
    	event.stopPropagation();
    	doData();
        
    });
    
    
    //조회버튼
    doRetrieveBtn.addEventListener("click",function(event){
    	event.stopPropagation();
    	doData();
    	
    });
    
    //화재요인버튼
    factorBtn.addEventListener("click",function(event){
    	event.stopPropagation();
    	div = 'factor';
    	workDiv = 'factor';
    	let searchDiv = '10';
    	midList.value = '';
    	
    	searchConditions.textContent = factorBtn.textContent;
    	
    	categoryBigList(searchDiv,div);
    });
    
    //화재장소버튼
    locationBtn.addEventListener("click",function(event){
    	event.stopPropagation();
        div = 'location';
       	workDiv = 'location';
        let searchDiv = '10';
        midList.value = '';
        
        searchConditions.textContent = locationBtn.textContent;
        
        categoryBigList(searchDiv,div);
    });
    
    //대분류 선택시
    bigList.addEventListener("change",function(event){
    	event.stopPropagation();
        let searchDiv = '20';
        let searchWord = bigList.value;
        
        selectedText = bigList.options[bigList.selectedIndex].textContent;
        let midselectedText = midList.options[0].textContent;
        
        if(div == 'factor'){
        	searchConditions.textContent = factorBtn.textContent;
        	searchConditions.textContent += ' - '+ selectedText;
        	searchConditions.textContent += ' - '+ midselectedText;
        }else{
        	searchConditions.textContent = locationBtn.textContent;
            searchConditions.textContent += ' - '+ selectedText;
            searchConditions.textContent += ' - '+ midselectedText;
        }
        
        if(bigList.value == '') {
        	midList.value = '';
        	if(div == 'factor'){
        		   searchConditions.innerHTML = factorBtn.textContent;
        	}else{
        		   searchConditions.innerHTML = locationBtn.textContent;
        	}
        }
        
        categoryMidList(searchDiv,div,searchWord,midList);
    	
        for (let i = 0; i < bigList.options.length; i++) {
            if (bigList.options[i].value === searchWord) {
                bigList.selectedIndex = i;
                break;
            }
        }
    });
    
    //소분류 선택시
    midList.addEventListener("change",function(event){
    	event.stopPropagation();
        let midselectedText = midList.options[midList.selectedIndex].textContent;
        
        if(div == 'factor'){
            searchConditions.textContent = factorBtn.textContent + ' - '+ selectedText;
            searchConditions.textContent += ' - ' + midselectedText;
        }else{
            searchConditions.textContent = locationBtn.textContent + ' - '+ selectedText;
            searchConditions.textContent += ' - ' + midselectedText;
        }
        
    });
    
    //코드 리스트 대+소분류 
    function categoryMidList(searchDiv,div,searchWord,select){
    	let url = '/ehr/firedata/cityList.do';
    	let params = {
   			"searchDiv": searchDiv,
            "div" : div,
            "searchWord" : searchWord
    	};
    	dataType = 'json';
    	type = 'GET';
    	async = 'true';
    	
    	PClass.pAjax(url, params,dataType,type,async,function(response){
    		if(response){
    			try{
    				let data = response;
                    
                    if(data ==''){
                    	select.innerHTML = '<option value="" disabled>전체</option>';
                    	select.selectedIndex = 0;
                    }else{
                    	select.innerHTML = '<option value="" >전체</option>';
                    }
                    
                    data.forEach(function(item){
                        
                        let html = '<option value="'+item.subCode+'">'+item.midList+'</option>';
                        select.innerHTML += html;
                        
                    });
    				
    			}catch(e){
    				console.error("data가 null혹은, undefined 입니다.",e);
   				    alert("data가 null혹은, undefined 입니다.");  
    			}
    			
    		}else{
    			console.error("통신실패!");
                alert("통신실패!");
    		}
    		
    	});
    	
    }
    
    //코드리스트 대분류-전체 검색
    function categoryBigList(searchDiv,div){
    	let url = '/ehr/firedata/cityList.do';
        let params = {
      		"searchDiv": searchDiv,
            "div" : div
        };
        dataType = 'json';
        type = 'GET';
        async = 'true';
        
        PClass.pAjax(url, params,dataType,type,async,function(response){
            if(response){
                try{
                	let data = response;
                    
                    bigList.innerHTML = '<option value="">전체</option>';
                    
                    data.forEach(function(item){
                        let html = '<option value="'+item.subCode+'">'+item.bigList+'</option>';
                        bigList.innerHTML += html;
                    });//forEach
                    
                }catch(e){
                    console.error("data가 null혹은, undefined 입니다.",e);
                    alert("data가 null혹은, undefined 입니다.");  
                }
                
            }else{
                console.error("통신실패!");
                alert("통신실패!");
            }
            
        });
    	
    }
    
    function doData(){
    	bigListText = bigList.options[bigList.selectedIndex].textContent
        midListText = midList.options[midList.selectedIndex].textContent
        sidoText = sido.options[sido.selectedIndex].textContent
        sigungoText = sigungo.options[sigungo.selectedIndex].textContent
        searchDiv = '';
        
        //console.log('workDiv: '+workDiv);
        //console.log('fRdateStart: '+fRdateStart.value);
        //console.log('fRdateEnd: '+fRdateEnd.value);
        //console.log('bigListText: '+bigListText);
        //console.log('div: '+div);
        //console.log('bigList.value: '+bigList.value);
        //console.log('midList.value: '+midList.value);
        //console.log('sido.value: '+sido.value);
        //console.log('sigungo.value: '+sigungo.value);
        
        if(workDiv == 'factor' && bigList.value != '' && midList.value == ''){
            searchDiv = '10';
        }else if(workDiv == 'factor' && midList.value != ''){
            searchDiv = '20';
        }else if(workDiv == 'location' && bigList.value != '' && midList.value == ''){
            searchDiv = '30';
        }else if(workDiv == 'location' && midList.value != ''){
            searchDiv = '40';
        }
        
        //console.log('searchDiv: '+searchDiv);
        if(bigList.value == '') bigListText = '';
        //console.log('midListText: '+midListText);
        if(sido.value == '') sidoText = '';
        //console.log('sidoText: '+sidoText);
        if(sigungoText === '전체') sigungoText = '';
        //console.log('sigungoText: '+sigungoText);
        
        if(workDiv == '' ){
        	alert('카테고리를 선택하세요');
        	return;
        }
        
        $('g').removeClass('d-none');
        CSVBtn.classList.remove('d-none');
        
        let url = '/ehr/firedata/totalData.do';
        let params = {
            "searchDateStart": fRdateStart.value,
            "searchDateEnd" : fRdateEnd.value,
            "BigNm" : bigListText,
            "MidNm" : midListText,
            "subCityBigNm" : sidoText,
            "subCityMidNm" : sigungoText,
            "searchDiv" : searchDiv
        };
        dataType = 'json';
        type = 'GET';
        async = 'true';
        
        PClass.pAjax(url, params,dataType,type,async,function(response){
            if(response){
                try{
                    let data = response;
                    //console.log('data[0].totalCnt:'+data[0].totalCnt);
                    //console.log('data[0].totalCnt:'+data[1].totalCnt);
                    
                    let tooltip = searchConditions.textContent;
                    let totalAmount = BigInt(data[0].amountSum);
                    let selectedAmount = BigInt(data[1].amountSum);
                    //console.log('totalAmount:'+totalAmount);
                    //console.log('selectedAmount:'+selectedAmount);
                    
                    columnChart(data[0],data[1]);
                    pieChart(data[0].totalCnt,data[1].totalCnt,fireCnt,'화재건수',tooltip);
                    pieChart(Number(totalAmount),Number(selectedAmount),fireAmount,'재산피해(천원)',tooltip);
                    /* pieChart(data[0].totalCnt,data[1].totalCnt,fireCnt,'화재건수',tooltip);
                    pieChart(data[0].amount,data[1].amount,fireAmount,'재산피해(천원)',tooltip); */
                                        
                }catch(e){
                    console.error("data가 null혹은, undefined 입니다.",e);
                    alert("data가 null혹은, undefined 입니다.");  
                }
                
            }else{
                console.error("통신실패!");
                alert("통신실패!");
            }
            
            
        });//아작스
        
        doDataList();
    }
    
    function doDataList(){
    	//총 계
        let totalCnt = 0;
        let injuredSum = 0;
        let dead = 0;
        let injured = 0;
        let amount = 0;
        let numFormat = new Intl.NumberFormat();
    	
    	let url = '/ehr/firedata/totalDataList.do';
        let params = {
            "searchDateStart": fRdateStart.value,
            "searchDateEnd" : fRdateEnd.value,
            "BigNm" : bigListText,
            "MidNm" : midListText,
            "subCityBigNm" : sidoText,
            "subCityMidNm" : sigungoText,
            "searchDiv" : searchDiv,
            "div" : workDiv
        };
        dataType = 'json';
        type = 'GET';
        async = 'true';
        
        PClass.pAjax(url, params,dataType,type,async,function(response){
        	if(response){
                try{
                    let data = response;
                    //console.log('List:'+data);
                    const thead = document.querySelector('#thead');
                    const tbody = document.querySelector('#tbody');
                    //console.log('table:'+table);
                    
                    let headerHtml = '<tr><th colspan="2">구분</th><th>화재 건수</th><th>총 인명피해</th><th>사망자</th><th>부상자</th><th>재산피해(천원)</th></tr>';
                    let html = '';
                    thead.innerHTML = headerHtml;

                    
                    data.forEach(function(item){
                    	html += '<tr>';
                    	
                    	html += '<td style="text-align: center;">'+item.subFactorBigNm+'</td>';
                    	html += '<td style="text-align: center;">'+item.subFactorMidNm+'</td>';
                    	html += '<td style="text-align: right;">'+numFormat.format(item.totalCnt)+'</td>';
                    	html += '<td style="text-align: right;">'+numFormat.format(item.injuredSum)+'</td>';
                    	html += '<td style="text-align: right;">'+numFormat.format(item.dead)+'</td>';
                    	html += '<td style="text-align: right;">'+numFormat.format(item.injured)+'</td>';
                    	html += '<td style="text-align: right;">'+numFormat.format(BigInt(item.amountSum))+'</td>';
                    	
                    	html += '</tr>';
                    	
                    	totalCnt   += Number(item.totalCnt);
                        injuredSum += Number(item.injuredSum);
                        dead       += Number(item.dead);
                        injured    += Number(item.injured);
                        amount     += Number(BigInt(item.amountSum));
                    });
                    let bodyhtml = '<tr>';
                    
                    bodyhtml += '<td colspan="2" style="text-align: center;">합계</td>';
                    bodyhtml += '<td style="text-align: right;">'+numFormat.format(totalCnt)+'</td>';
                    bodyhtml += '<td style="text-align: right;">'+numFormat.format(injuredSum)+'</td>';
                    bodyhtml += '<td style="text-align: right;">'+numFormat.format(dead)+'</td>';
                    bodyhtml += '<td style="text-align: right;">'+numFormat.format(injured)+'</td>';
                    bodyhtml += '<td style="text-align: right;">'+numFormat.format(amount)+'</td>';
                    
                    bodyhtml += '</tr>';
                    
                    tbody.innerHTML = bodyhtml;
                    tbody.innerHTML += html;
                    	
                }catch(e){
                    console.error("data가 null혹은, undefined 입니다.",e);
                    alert("data가 null혹은, undefined 입니다.");  
                }
        	}else{
                console.error("통신실패!");
                alert("통신실패!");
            }
        	
        });
    	
    }
    
    function pieChart(totalData, data, id, title,tooltip) {
        Highcharts.chart(id, {
            accessibility: {
                enabled: false
            },
            chart: {
                type: 'pie',
                backgroundColor: '#f8f9fa'
            },
            title: {
                text: title
            },
            subtitle: {
                text: '비교기준 : 전국'
            },credits: {
                enabled: false
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: true,
                        formatter: function() {
                            return this.point.name + ': ' + Highcharts.numberFormat(this.point.y, 0) + ' (' + Highcharts.numberFormat(this.point.percentage, 1) + '%)';
                        },
                        distance: 20,
                        style: {
                            fontSize: '0.8em',
                            textOutline: 'none',
                            opacity: 0.7
                        },
                        filter: {
                            operator: '>',
                            property: 'percentage',
                            value: 0
                        }
                    }
                }
            },
            series: [
                {
                    name: title,
                    colorByPoint: true,
                    data: [
                        {
                            name: tooltip,
                            y: data
                        },
                        {
                            name: '전국/ ' + tooltip,
                            y: totalData
                        }
                    ]
                }
            ],
            tooltip: {
                formatter: function() {
                    return this.point.name + ': ' + Highcharts.numberFormat(this.point.y, 0) + ' (' + Highcharts.numberFormat(this.point.percentage, 1) + '%)';
                }
            }
        });
    }
    
    function columnChart(totalData,data){
    	const chart = Highcharts.chart('result', {
    		accessibility: {
                enabled: false
            },
            
    	    chart: {
    	        type: 'column',
    	        backgroundColor: '#f8f9fa'
    	    },

    	    title: {
    	        text: '통계 데이터'
    	    },

    	    subtitle: {
    	        text: '비교 기준 : 전국'
    	    },credits: {
                enabled: false
            },

    	    legend: {
    	        align: 'right',
    	        verticalAlign: 'middle',
    	        layout: 'vertical'
    	    },

    	    xAxis: {
    	        categories: ['총 인명피해', '사망자' , '부상자'],
    	        labels: {
    	            x: -10
    	        }
    	    },

    	    yAxis: {
    	        allowDecimals: false,
    	        title: {
    	            text: '피해인원(명)'
    	        }
    	    },

    	    series: [{
    	        name: '전체',
    	        data: [totalData.injuredSum, totalData.dead,totalData.injured]
    	    }, {
    	        name: '선택지역',
    	        data: [data.injuredSum, data.dead,data.injured]
    	    }],

    	    responsive: {
    	        rules: [{
    	            condition: {
    	                maxWidth: 500
    	            },
    	            chartOptions: {
    	                legend: {
    	                    align: 'center',
    	                    verticalAlign: 'bottom',
    	                    layout: 'horizontal'
    	                },
    	                yAxis: {
    	                    labels: {
    	                        align: 'left',
    	                        x: 0,
    	                        y: -5
    	                    },
    	                    title: {
    	                        text: null
    	                    }
    	                },
    	                subtitle: {
    	                    text: null
    	                },
    	                credits: {
    	                    enabled: false
    	                }
    	            }
    	        }]
    	    }
    	});

    }
    
});   
</script>
</head>
<body>
<jsp:include page="/WEB-INF/views/header.jsp" />

<section class="content content2 align-items-center">
    <h3>화재통계</h3>
    
    <!-- 카테고리 버튼 -->
    <div class="select_date row g-1 d-flex align-items-center">
        <button type="button" class="btn btn-success me-1" id = "factor">화재요인</button> 
        <button type="button" class="btn btn-secondary" id = "location">화재장소</button>
    </div>
    <!-- //카테고리 버튼 -->
    
    <form name = "fRfrm" id = "fRfrm" class="row g-1">
        <select class="me-2 col form-select" name="bigList" id="bigList">
            <option value="">대분류</option>
        </select>
        <select class="col form-select" name="midList" id="midList">
            <option value="">전체</option>
        </select>
    </form>
    
    <div class="input_date">
         <!-- 상단 좌측 검색 조건 -->
         <div class="search-conditions">
             <p class="form-control work_div_result">검색 조건 : <span id="searchConditions"></span></p>
         </div>
         
         <!-- 하단 좌측 검색 날짜 -->
         <div class="search-date">
             <p class="m-0"><i class="bi bi-calendar"></i> 검색기간 : </p>
             <input type="date" class="form-input" name="fRdateStart" id="fRdateStart" min="${minMaxDate.regDt}" max="${minMaxDate.modDt}">
             <p class="m-0"> - </p>
             <input type="date" class="form-input" name="fRdateEnd" id="fRdateEnd" min="${minMaxDate.regDt}" max="${minMaxDate.modDt}">
         </div>
         
         <!-- 우측 하단 버튼들 -->
         <div class="buttons">
             <button type="button" class="btn btn-success" id="doRetrieve">조회</button> 
             <button type="button" class="btn btn-success" id="resycle">초기화</button> 
         </div>
     </div>
    
    <form name = "cityfrm" id = "cityfrm" class="row g-1">
        <select class="me-2 col form-select" name="sido" id="sido">
            <option value="">시도(전체)</option>
            <c:forEach var="item" items="${cityList}">
               <option value="${ item.subCode }">${item.bigList }</option>   
            </c:forEach>
        </select>
        <select class="col form-select" name="sigungo" id="sigungo">
            <option value="">전체</option>
        </select>
    </form>
    
    <div class="svgBox">
    <!-- (c) ammap.com | SVG map of South Korea - High -->
        <div class="svgBoxInner1">        
		  <svg xmlns="http://www.w3.org/2000/svg" class="map" viewBox="0 30 500 770">
		    <defs>
	        <amcharts:ammap projection="mercator" leftLongitude="125.384458" topLatitude="38.612296" rightLongitude="131.873029" bottomLatitude="33.194027"></amcharts:ammap>
	
	        <!-- All areas are listed in the line below. You can use this list in your script. -->
	        <!--{id:"KR-11"},{id:"KR-26"},{id:"KR-27"},{id:"KR-28"},{id:"KR-29"},{id:"KR-30"},{id:"KR-31"},{id:"KR-41"},{id:"KR-42"},{id:"KR-43"},{id:"KR-44"},{id:"KR-45"},{id:"KR-46"},{id:"KR-47"},{id:"KR-48"},{id:"KR-49"},{id:"KR-50"}-->
	
		    </defs>
			    <g class="d-none">
			        <path id="KR-11" title="11000" class="land" d="M132.666,290.394L133.241,290.724L133.241,290.724L137.041,294.54L136.937,296.315L137.487,296.841L137.801,299.933L138.377,300.458L138.927,300.36L141.337,299.11L143.906,304.796L144.43,304.928L146.236,304.206L147.442,304.698L149.828,304.599L153.994,302.298L157.059,302.003L157.059,303.712L157.74,304.928L161.382,302.856L164.369,302.595L166.047,301.018L165.599,300.458L166.02,299.868L166.649,300.032L167.278,299.57L168.562,297.861L168.562,297.268L167.383,296.775L167.776,294.277L168.771,293.289L170.527,292.664L170.971,292.138L170.316,289.735L169.531,288.583L168.376,289.407L165.917,290L164.736,290.756L163.558,290.92L163.19,290.329L163.165,289.144L164.605,284.995L163.504,283.283L163.426,281.438L162.535,280.286L162.429,275.77L161.512,274.683L160.334,274.485L157.713,274.814L155.382,274.288L154.465,275.276L153.208,275.804L152.656,276.331L152.684,277.517L151.583,278.572L151.505,281.57L150.403,282.361L145.268,282.756L144.43,283.81L144.272,286.904L143.645,287.268L140.027,288.879L137.618,287.728L136.229,286.016L134.97,285.687L133.949,288.156L132.796,289.144z"/>
			        <path id="KR-26" title="21000" class="land" d="M361.126,544.718l0.044,0.762h3.965l1.338,1.338l0,0l1.002,1.671l-0.167,1.506l-0.898,0.319l-0.603,0.768l-0.367,1.022l0.262,1.663l-0.732,2.332l-0.866,-0.063l-0.104,0.924l-0.89,0.129l0.575,0.544l1.024,-0.352l0.313,1.628l-1.415,3.034l-0.629,-0.032l-0.341,-0.479l-0.603,1.406l0.786,1.372l-0.078,0.479h-0.446l-0.026,1.244l-0.498,0.256l-0.313,-0.448l-0.525,0.735l-0.996,0.127l-0.575,2.203l-0.76,0.159l-0.367,0.543l-1.651,-0.607l-0.604,0.096l-0.681,0.829l-1.651,-1.083l0.105,0.797l-1.624,0.224l-0.235,0.541l0.288,0.862l-0.655,0.67l1.021,0.158l0.523,1.501l-0.13,2.614l-1.179,-0.638h-0.708l-0.287,0.509l-0.918,-0.19l-0.104,-1.021l-0.21,0.638l-1.938,-0.255l0.209,-1.977l-0.707,-0.447l-0.576,0.797l-1.207,0.511l-0.313,0.573l0.235,0.383l-1.625,1.722l-0.21,1.785l-0.813,0.098l0.681,1.433l-0.706,1.146l-0.917,-2.038l-0.184,-1.531l-1.074,0.191l0.916,3.855l-0.34,0.542l-0.603,-0.127l-0.158,-1.467l-0.968,-0.349l-0.289,0.668l0.629,0.16l-0.131,0.828l-1.154,-0.128l0.683,0.924h-0.445l-0.733,0.828l0.104,-1.752l-0.733,-0.382l-0.813,-3.314l0.551,-3.028l-0.577,-0.064l-0.341,1.722l-1.153,0.766l-0.131,-1.18l0.472,-1.594l-0.418,-0.097l-0.682,2.009l-1.258,0.734l-0.027,0.859h-1.648l0.497,-3.793l0.524,-0.733l-1.05,-0.383l-0.97,4.909l-1.493,-0.51h-2.935l-1.493,-1.626l-0.236,0.701l-1.545,0.16l-1.152,1.308l-0.523,-0.064l-0.236,-0.828l0.76,-1.053l0.862,0.159l0.211,-0.637l-1.259,0.191l0.315,-2.32l0,0l0.2,-0.464l2.428,-1.001l4.286,-1.144l0.429,-4.998l2.286,-0.287l3.856,-2.428l4.143,-0.143l1.429,-1.572l0.857,-1.999l0.791,-0.198l0.977,-1.162l3.943,-2.476l1.832,0.316l1.029,-1.339l0.856,-2.714l1.714,-2.571l4.857,-0.571l0.572,-1.857l2.943,-2.706l0,0L361.126,544.718zM346.653,575.535l1.86,1.594l-0.289,1.626l1.939,1.626l-0.499,1.083h-0.891l-0.471,-1.18l-0.629,0.256l-0.498,-0.479l-0.078,-0.795l-1.311,-0.415l-1.808,-1.881l0.025,-0.477l0.813,-0.512L346.653,575.535z"/>
			        <path id="KR-27" title="22000" class="land" d="M297.124,513.416L296.346,514.417L295.542,517.999L294.465,518.592L292.05,517.701L292.05,517.701L290.53,518.076L290.53,518.076L287.047,520.567L284.639,520.627L284.639,520.627L283.907,517.206L279.858,512.224L280.17,509.422L282.038,510.044L283.595,511.29L285.774,511.29L286.397,508.799L283.284,505.374L284.529,502.26L285.774,499.458L291.068,498.524L290.757,496.655L287.955,494.476L283.284,494.164L283.595,491.051L284.84,488.248L287.02,485.135L289.2,484.512L291.068,483.266L291.69,488.871L294.182,488.871L295.115,485.758L297.607,480.774L303.522,479.53L306.326,476.416L309.75,475.481L312.863,475.793L316.601,478.907L316.601,483.266L317.224,486.379L319.092,490.427L318.158,492.607L314.733,493.853L313.176,497.277L313.176,500.391L310.685,500.703L310.685,502.572L311.931,504.129L311.931,508.177L308.505,509.422L306.948,511.29L304.146,510.978L303.522,508.177L300.409,508.177L298.23,509.422L296.673,511.913z"/>
			        <path id="KR-28" title="23000" class="land" d="M113.224,287.19l2.449,-1.982l1.688,-0.728l0.614,-1.573l1.495,-1.266l2.071,0.192l7.439,6.02l0,0l3.817,1.289l-0.132,1.251l0.576,0.33l0,0l-3.536,4.536l0,0l0.13,4.016l3.301,2.892l0,0l0.027,1.182l-0.709,0.79l-0.024,0.657l0,0l0.262,1.149l-0.943,0.821l0,0l-0.55,0.426l-0.29,1.074l0,0l-0.553,-0.164l-0.131,-0.197l-1.31,-0.229l0.472,-1.807l-0.682,-0.526l-0.262,0.065l0.603,0.493l-0.131,0.756l-0.603,0.36l-0.288,-2.2l-0.315,-0.132l0.052,2.267l0.419,0.23l-0.026,0.493l-1.965,2.266l-3.564,-0.493l-3.668,4.628l-3.197,0.033h-0.131l-1.258,0.098l-0.341,1.083l-0.996,-0.033l0.838,-0.263l0.524,-1.837h2.175l-0.445,0.82h2.83l3.589,-4.497l-1.336,-0.427l-2.698,-2.726l-0.944,-4.271l-0.497,2.3l-1.467,-0.099l0.366,-0.821l-0.497,-0.723l0.681,-0.099l-0.472,-0.394l0.106,-0.559l-0.814,1.282l-0.969,-0.098l-0.236,-0.394l0.367,-1.38l-0.209,-0.888l0.603,-0.033l-0.34,-0.822l0.785,-1.512l2.988,-1.184l1.231,0.394l-0.76,-0.538l-0.158,-1.139l-1.048,0.987l-1.362,0.131l0.053,-1.316l-0.734,-0.394l-0.288,-0.691l0.969,0.099l-0.157,-1.25h-0.577l-0.051,-0.824h-0.525l-0.078,-0.428l0.682,-0.295l0.052,-1.415l-2.62,1.019l-0.158,0.625l-0.393,-0.395l-0.603,0.23l-2.306,2.012l2.201,-2.078l3.904,-1.613l-0.838,-1.054l-0.734,-0.131L113.224,287.19zM87.28,288.803l1.756,0.89l0.078,0.362l0.865,-0.263l0.524,1.546l0.892,0.46l2.96,-0.427l-0.262,1.447l-2.044,-0.427l-1.861,0.625l-0.052,-0.559h-0.341l-1.021,0.954l0.367,-2.105l-1.939,-1.909L87.28,288.803zM106.879,291.962l0.76,0.724l-0.026,0.461l3.564,0.986l0.55,0.921l0.838,0.394l0.42,1.842l-2.253,1.414l-1.39,-0.066l-0.602,-0.591l-0.996,1.249l-2.123,0.954l-1.729,2.235l-4.009,2.924l-1.546,-0.197l-1.31,0.755l-0.053,-0.525l0.577,-0.328l-0.184,-1.117l-0.943,-0.657l-1.231,0.821l0.891,-0.92l-0.472,-0.723l-0.734,0.229v0.789l-0.628,-0.526l-0.235,0.756l-0.524,-0.723l-1.101,-0.099l0.864,-0.624l-0.471,-0.165l0.131,-0.953l-0.551,0.065l-0.654,-0.724l-0.184,-0.689l0.418,-0.69l1.651,-0.033l3.931,-2.794l5.554,-0.263l1.337,-0.954l0.681,-2.697L106.879,291.962zM97.053,306.592l0.105,0.821l0.786,0.263l0.786,1.281l1.102,0.525l-0.079,0.591l-0.629,-0.066l0.577,0.427l-0.708,0.493v0.689l-1.571,0.427l-0.944,-0.919l0.367,-1.248l-0.262,-0.689l-1.179,-0.296l0.813,-1.446l0.078,-0.985L97.053,306.592z"/>
			        <path id="KR-29" title="24000" class="land" d="M150.742,562.137L148.806,559.802L146.98,558.934L144.547,558.848L142.114,559.802L140.115,560.846L138.117,562.931L136.639,563.018L134.553,562.321L133.076,560.932L132.468,558.76L130.295,558.673L128.209,563.975L125.863,563.888L124.125,565.973L122.995,570.753L123.43,574.837L130.643,575.879L132.468,578.139L134.38,581.963L138.117,581.963L141.506,579.964L145.329,579.964L146.807,578.922L149.935,579.529L153.324,577.183L154.714,575.358L155.497,573.707L155.584,571.1L156.453,569.274L156.453,567.884L154.367,566.929L151.76,566.667z"/>
			        <path id="KR-30" title="25000" class="land" d="M192.048,423.476L192.356,423.646L192.356,423.646L192.841,423.558L193.818,421.286L193.818,421.286L194.428,420.64L194.428,420.64L195.811,420.82L195.487,422.123L195.487,422.123L195.419,422.76L195.419,422.76L195.425,423.018L198.277,420.368L198.277,420.368L200.769,422.859L200.769,422.859L201.007,425.477L201.663,426.219L203.43,426.63L203.113,428.254L203.883,428.463L205.128,430.644L203.883,430.954L202.326,432.512L202.326,432.512L201.391,438.116L201.391,438.116L200.146,444.344L201.312,448.082L201.312,448.082L197.966,450.26L195.788,453.063L192.05,450.883L189.871,447.146L189.871,445.277L189.248,443.721L187.691,443.721L188.002,446.835L187.379,451.816L186.445,453.996L185.2,453.996L184.266,450.883L181.775,449.948L180.218,447.769L179.906,444.344L177.727,442.476L177.416,438.428L179.596,435.937L179.283,427.218L179.283,427.218L181.798,426.639L181.798,426.639L182.709,426.596L186.134,425.039L187.068,422.235L187.396,418.957L187.087,418.922L187.087,418.922L186.859,418.604L190.805,418.188z"/>
			        <path id="KR-31" title="26000" class="land" d="M360.327,508.995L362.125,510.462L364.134,510.771L365.103,511.357L365.339,512.182L365.339,512.182L364.915,515.018L364.915,515.018L365.201,515.789L365.931,516.123L365.931,516.123L367.902,516.772L367.902,516.772L369.325,516.531L372.144,514.691L373.257,514.386L373.257,514.386L374.741,514.375L374.741,514.375L379.619,516.104L379.619,516.104L381.377,516.527L381.377,516.527L384.267,516.936L384.961,518.386L384.933,519.764L384.2,519.956L383.808,520.535L384.332,523.677L383.729,524.734L383.678,526.081L383.571,526.433L382.55,526.594L382.575,527.074L383.31,526.689L383.125,528.26L381.921,528.774L381.946,529.062L382.786,528.901L382.917,529.511L381.658,530.118L381.841,530.567L382.786,530.183L383.15,530.823L382.682,530.76L382.13,532.009L381.135,531.593L381.213,531.945L380.218,532.072L380.27,532.585L379.745,533.065L379.327,532.875L379.091,531.399L379.483,530.408L378.854,529.573L378.331,529.511L378.515,528.133L377.701,526.562L375.764,524.444L374.27,523.965L374.27,524.639L375.658,525.12L376.575,526.306L376.497,527.428L377.466,527.684L377.388,528.516L377.807,529.126L377.491,529.573L376.968,529.35L375.947,529.701L375.449,529.255L375.973,529.958L376.941,529.701L377.833,531.272L377.204,531.721L377.073,532.875L376.418,533.098L375.239,534.508L374.558,534.476L374.06,533.355L373.011,532.811L373.693,533.61L373.772,535.819L374.06,536.077L374.924,535.756L374.426,536.749L375.789,536.013L375.371,536.749L375.789,537.613L375.475,537.998L374.453,538.062L374.218,538.829L374.609,539.981L375.317,539.981L375.344,540.558L374.847,540.718L374.558,542.126L373.744,542.478L373.534,543.47L373.641,544.206L374.609,544.493L375.317,545.965L373.824,546.828L373.272,546.284L372.645,546.348L372.147,547.468L371.544,547.437L371.44,548.108L370.941,548.331L370.628,549.419L369.553,549.482L369.29,550.664L368.139,550.537L367.851,549.739L367.307,549.994L367.476,548.487L366.473,546.817L366.473,546.817L365.135,545.479L361.17,545.479L361.126,544.718L361.126,544.718L359.586,542.837L359.586,542.837L356.504,542.629L356.504,542.629L354.279,540.747L350.855,536.773L350.855,536.773L347.603,533.426L345.207,533.218L345.207,533.218L342.469,533.218L340.242,532.171L339.901,527.356L342.126,525.471L342.126,525.471L343.324,524.424L343.324,522.959L341.858,520.538L341.858,520.538L345.771,517.456L345.771,517.456L347.428,517.281L347.428,517.281L348.1,517.412L348.755,516.549L347.404,514.074L347.182,513.014L347.775,512.521L351.921,509.947L355.028,508.929L356.651,509.228L359.236,508.572z"/>
			        <path id="KR-41" title="31000" class="land" d="M79.105,265.799l-1.729,-1.485l-0.079,-0.595l0.838,-0.495l0.682,-1.156l-0.158,-1.188l0.368,-1.089l1.571,-1.486l0.839,0.296l1.808,-0.296l3.039,1.75h1.546l0.839,-0.661l1.074,1.188l-1.703,2.774l-1.965,1.188l-2.62,-0.33l-0.787,0.528l-1.441,0.066l-1.047,1.419L79.105,265.799zM89.69,323.951l-0.366,0.525l-0.341,-0.263l-0.209,0.426l-1.389,-0.885l-0.446,0.197l-1.518,-0.492l-0.08,-0.59l-0.812,0.165l0.209,0.753l-0.472,0.328l1.257,1.213l0.105,-0.426l0.498,0.492l0.891,-0.131l0.21,0.786l0.184,-0.426l0.418,0.033l0.419,0.557l2.07,-0.524l0.734,-1.212l-0.839,-0.525H89.69zM81.935,280.175l-0.052,-0.988l0.498,-0.89l-0.263,-0.495l-1.52,0.066l-0.68,-0.396L79,277.704l-0.079,0.593l1.389,1.482l1.861,1.021l0.551,0.758l0.34,-0.56l-0.471,-0.495L81.935,280.175zM70.485,325.852l-0.237,-0.557l-0.917,0.624l-0.079,-1.345l-0.393,-0.033l-0.289,-1.475l-0.603,-0.425l-0.498,0.262l0.183,0.459l-1.179,2.491l0.079,2.163l-0.603,0.884l1.257,-0.196l-0.209,-0.458l0.393,-0.329l0.394,1.278l1.152,-0.36l0.132,0.721l-0.655,0.328l0.367,0.393l1.755,-0.327l0.603,0.229l0.131,-0.524l0.892,0.098l0.052,-0.557l1.546,-1.31l-0.289,-0.295L70.485,325.852zM76.616,273.749l-0.366,-0.132l-1.258,1.517l-1.047,-0.363l-1.337,0.396l0.104,0.494l1.179,0.726l1.153,-0.495l0.942,0.693l-0.078,0.791l0.472,-0.198l1.388,0.527l-0.288,-0.758l0.576,-0.692l-1.075,-1.055L76.616,273.749zM159.53,204.022l-5.561,4.256l-1.001,1.827l-3.889,3.976h-2.802l-4.671,-1.869l-2.491,1.557l-2.802,1.869l-2.802,2.802l-3.425,4.982l1.868,0.934l1.869,3.737l6.295,0.289l3.358,1.89l0.623,3.114l-1.246,0.934l-0.312,1.869l-2.179,-0.623h-2.802l-0.312,3.736l-1.557,0.935l0.312,2.491l1.867,0.934l-0.311,6.54l-2.18,1.246l-1.557,-2.491l-1.557,-1.245l1.245,-4.36l-1.954,-2.464l-2.398,0.072l-0.318,2.703l-1.868,1.869l-3.467,-3.335l-0.74,0.107l-0.274,0.837l1.169,4.054l-0.485,1.865l3.486,0.83l1.246,0.934l3.425,4.983l-6.54,1.868h-2.829l-0.959,4.536l-2.997,0.176l-1.116,0.526l-1.952,1.933l-3.555,-0.528l-2.017,-1.604l-0.603,1.171l-1.074,0.099l-0.681,0.693l1.1,1.749l-0.865,4.223l1.074,1.781l0.079,1.484l-0.577,1.615l1.153,0.527l-0.052,1.253l-0.708,0.461l1.677,3.031l0.969,3.294l2.362,3.095l0,0l2.449,-1.982l1.688,-0.728l0.614,-1.573l1.495,-1.266l2.071,0.192l7.439,6.02l0,0l3.816,1.29l0,0l1.152,-0.988l1.021,-2.469l1.259,0.329l1.389,1.711l2.41,1.152l3.617,-1.612l0.628,-0.363l0.158,-3.095l0.837,-1.054l5.136,-0.395l1.102,-0.791l0.077,-2.998l1.101,-1.056l-0.028,-1.186l0.552,-0.527l1.257,-0.527l0.917,-0.989l2.331,0.527l2.621,-0.33l1.178,0.198l0.917,1.087l0.106,4.516l0.891,1.152l0.078,1.845l1.102,1.712l-1.441,4.148l0.025,1.185l0.368,0.592l1.179,-0.164l1.18,-0.757l2.46,-0.593l1.154,-0.823l0.785,1.152l0.655,2.403l-0.444,0.526l-1.756,0.625l-0.995,0.988l-0.394,2.498l1.179,0.493v0.593l-1.284,1.709l-0.629,0.461l-0.629,-0.164l-0.421,0.591l0.449,0.559l-1.678,1.577l-2.987,0.262l-3.642,2.071l-0.682,-1.216v-1.708l-3.064,0.295l-4.167,2.301l-2.385,0.099l-1.207,-0.492l-1.806,0.722l-0.524,-0.131l-2.569,-5.686l-2.41,1.25l-0.55,0.098l-0.576,-0.526l-0.314,-3.091l-0.55,-0.526l0.104,-1.775l-3.799,-3.816l0,0l-3.536,4.536l0,0l0.13,4.015l3.301,2.893l0,0l0.027,1.182l-0.709,0.79l-0.024,0.657l0,0l0.262,1.149l-0.943,0.821l0,0l-0.55,0.426l-0.29,1.074l0,0h0.81l0.418,0.591l-3.956,-0.755l-0.891,1.051l0.813,0.623l-0.393,1.511l-1.965,1.642l-0.76,-0.066l-0.471,0.689l-1.495,0.361l-0.261,0.951l0.524,0.131l0.027,0.427l-7.468,2.559l-2.934,2.231l-0.917,-0.263l0.472,0.983l-1.284,1.378l-0.577,-0.033l-0.027,-0.657l-2.279,-0.688l2.122,2.197l0.314,1.475l0.446,0.361l-0.342,2.065l-0.471,0.426l-1.101,-0.032l-0.236,0.721l0.105,0.655l1.101,0.065l0.236,0.753h-1.206l0.288,0.853l-0.603,0.163l-0.471,0.917l0.393,0.263l0.55,-0.885l0.707,-0.065l1.022,1.572l0.708,-0.752l-0.209,-0.624l0.628,-1.343l0.708,-0.655l0.864,0.688l0.576,-0.065l0.498,0.852l0.368,-0.491l0.707,0.557l-0.209,-1.245l0.995,-2.064l0.262,1.638l1.992,1.245l-0.498,0.688l-0.026,1.016l0.576,0.622l0.367,-0.852l-0.184,-0.721l0.603,-0.753l-0.341,-1.638l-2.621,-1.343l-0.236,-1.441l-0.524,-0.427l0.131,-0.82l-0.942,-0.458l-1.258,0.065l-0.969,-1.344l-1.153,-0.656l1.101,-1.147l-0.078,-0.656l3.196,-2.23l6.472,-2.231l0.996,-0.066l3.511,2.789l4.848,1.804l3.092,-0.394l1.153,2.099l1.047,0.427l0.55,0.754l1.258,-0.426l-0.864,0.819l-0.131,0.95l-1.573,-2l-0.471,0.361l-1.441,-0.853l0.157,-0.918l-0.891,0.328l-0.34,0.787l0.76,0.557l0.183,0.722l-1.101,-0.557l-0.812,0.458l0.733,1.737l-0.917,0.853l0.655,0.196l-0.707,0.196l0.314,0.492l-1.834,2.653l-0.34,-0.589l-0.97,-0.295l0.577,-0.688l-0.473,-0.655l-0.131,-2.36l-2.646,0.853l-0.341,-1.082l-0.891,0.131l-2.673,-0.884l-0.891,1.114l0.158,0.721l-1.704,0.36l0.393,1.737l0.524,-0.197l0.394,0.787l-0.917,0.786l-0.026,0.951l0.969,1.539l-1.414,0.033l-1.153,1.474l1.179,2.587l-1.074,0.95l0.995,-0.033l0.499,-0.59l0.262,0.394l1.284,-0.394l0.105,0.655l0.786,-0.164l-1.337,1.833l-0.891,0.295l0.315,0.393l0.576,-0.164l0.393,0.589l0.341,1.243l-0.524,0.523l0.838,0.786l0.394,-1.604l0.89,-0.261l0.473,-0.916l0.55,-0.033l0.079,0.327l1.363,-1.014l2.069,-3.405l2.542,0.229l0.367,-0.59l0.446,0.033l0.577,-1.572l-0.027,1.212l0.682,0.196l-0.21,0.721l0.498,0.262l-2.149,1.309l4.665,0.066l0.052,0.36l-2.123,0.229l0.944,0.556l-0.026,0.459l-0.813,-0.36l-0.34,0.818l-1.021,0.491l-1.049,-0.72l-2.017,1.93l-0.184,0.916l0.708,1.8l-0.473,4.349l-0.366,0.459l-0.236,0.032l-0.944,1.438l-0.026,0.817l0.367,0.785l3.485,-0.033l0.812,0.36l0.288,2.09l-0.497,-0.196l-0.839,0.622l0.052,0.816l0.55,0.523l1.808,-0.197l1.545,0.491l1.494,2.581l0.288,1.012l-0.655,-0.359l0.498,0.915l1.912,0.783l0.446,1.861l1.939,-0.327l1.415,0.914l0.864,4.55l0,0l0.986,-0.056l0.827,-1.208l1.638,-0.809l7.535,1.758l0.832,-0.612l0.938,0.005l3.158,-1.162l3.004,-2.065l2.578,-0.084l2.982,1.423l1.335,1.794l1.945,1.582l5.085,0.697l0,0l2.758,-0.231l0,0l1.517,-0.909l0,0l1.557,-0.35l0,0l0.699,-0.44l0,0l1.701,-1.235l2.206,0.136l0.905,-1.351l0.886,-0.394l0.165,-2.104l-0.302,-1.083l0,0l1.99,-1.591l0,0l3.087,-1.411l-0.179,-0.447l0.927,-1.142l0.05,-1.035l2.334,-2.564l0.801,1.188l1.479,-0.022l-0.272,2.065l1.596,-3.218l4.293,0.78l4.048,-3.736l2.49,-0.312l0.624,-7.784h1.557l1.557,1.868h1.869l2.656,-6.632l2.643,-0.582l0,0l0.616,-7.42l-0.623,-3.425l1.557,-1.246l-0.312,-7.473l3.426,-8.095l0.311,-4.048l-1.949,-0.709l-0.785,-2.376l2.766,-3.131l0.365,-0.892l2.06,-0.701l0.793,-2.179l-1.269,-1.545l-0.38,-1.35l-2.239,0.167l-0.851,-0.786l-2.28,-0.624l-3.58,-0.12l-4.298,-3.687l-2.684,-0.324l-1.813,-1.454l-2.292,-1.02l-3.631,1.398l-1.281,-0.91l-1.354,-1.928l1.745,-3.505l0.31,-4.379l-1.552,0.552l-0.746,-0.138l-0.657,0.635l-0.627,-0.148l0.12,-2.019l2.152,-1.85l0.541,-1.222l-1.318,-3.498l0.007,-0.914l0.816,-1.042l-0.199,-1.746l-0.647,-1.196l0.588,-1.521l2.257,-0.75l1.795,-2.061l2.613,-0.569l0.691,-0.5l0.998,-3.959l-0.816,-4.026l-1.441,-1.586l-2.009,-0.386l-2.187,-1.031l-0.083,-2.696l-0.879,-0.602l-3.212,0.341l-3.088,-1.525l-1.252,-1.59l-0.301,-1.426l-0.402,-7.5l-1.421,-1.968l-0.733,-0.092l-1.22,1.135l-0.696,-0.958l-1.393,-0.589l-1.483,0.195l-2.364,0.81l-1.213,1.404l-0.521,-0.286l-1.913,-2.173l-1.355,-0.213l-1.19,-1.191l-0.311,-1.967l0.543,-1.122l0.25,-2.223l1.09,-0.918l-1.967,-0.876l-0.566,0.04l-1.407,1.304l-1.681,2.392l-2.431,0.162l-1.64,-0.829l-0.508,-0.936l0.115,-2.247l-0.992,0.31l-0.179,-1.074l0.623,-1.868l-1.558,-1.246l-0.934,-5.294h-4.67v-1.868l1.246,-0.935l-4.728,-4.408L159.53,204.022zM93.831,274.209l-1.074,-0.791l0.026,-0.495l-2.489,-0.363l-2.097,-1.649l-0.026,-2.309l1.022,-2.079l-0.917,-0.561l-3.223,1.32l-0.079,3.399l-0.236,0.396l-1.022,-0.231l-0.262,0.396l1.861,1.714l2.725,1.45l1.022,1.451l-0.263,2.078l1.257,0.625l-0.183,0.429h0.734l-0.21,-0.758l3.04,-1.978L93.831,274.209zM107.377,277.803l0.21,-0.561l0.759,-0.197l-0.026,-0.461l-1.127,-0.462l-0.34,-0.89l0.786,-3.166l-0.864,-0.759l-0.289,-0.956l0.131,-1.221l0.97,-1.419l0.131,-1.088l-1.363,-1.683l0.158,-1.023l-0.498,-1.254l-4.506,-2.939l-2.149,-2.774l-0.995,-0.231l-0.577,0.792l-2.358,0.166l-0.838,2.014l-3.485,1.882l0.603,3.434l-0.42,2.672l0.341,3.958l2.987,0.792l0.393,0.56l-0.235,0.792l1.362,1.318l0.446,1.912l-0.158,1.483l-0.707,0.89l-3.17,0.593l0.813,0.527l0.34,1.548l-0.708,0.461l0.131,0.33l0.418,-0.066l1.258,1.185l1.258,0.198l0.34,0.626l5.345,0.362l0.027,-1.021l0.891,0.428l0.577,-0.922l2.2,0.988l0.943,-0.066l0.812,-1.647l1.364,-0.395l0.052,-0.56L107.377,277.803zM104.311,321.591l-0.917,0.131l-0.602,-0.754l-1.546,0.558l-0.393,-0.131l-0.341,0.59l0.157,0.689l-1.545,-0.131l-0.158,1.246l-0.551,0.263l0.446,0.294l0.367,1.672l-0.498,0.164l0.158,1.705l1.885,-0.033l0.315,0.393l-0.262,0.524l0.629,-0.065l0.445,-0.721l0.892,-0.393l-0.262,-0.853l1.519,-0.098v-0.492l-0.524,0.131l0.027,-0.525l-0.656,-0.426l0.734,-0.295l0.524,0.262l-0.209,-0.754l0.995,0.722l0.419,-0.426l0.262,-1.541l-0.472,-0.886L104.311,321.591z"/>
			        <path id="KR-42" title="32000" class="land" d="M280.677,163.387L282.091,166.192L284.24,168.929L284.816,168.762L285.602,170.497L285.576,171.231L285.052,171.765L285.733,172.565L285.655,173.099L286.808,174.1L286.23,175.401L286.598,176.201L287.383,176.401L287.227,177.868L288.222,178.635L288.039,179.468L288.721,179.835L290.922,182.734L290.476,183.301L290.319,183L289.795,183.234L289.743,184.933L293.515,190.727L295.245,192.524L294.616,192.957L294.878,194.621L296.476,196.85L296.449,198.314L298.756,200.309L298.519,202.005L299.516,203.866L299.593,205.926L303,210.91L303.578,211.109L302.843,211.507L302.764,212.238L304.782,214.96L303.865,215.956L304.363,217.814L304.205,218.744L304.782,220.004L305.699,221.298L306.38,221.563L307.35,223.687L308.765,225.41L310.362,226.571L311.071,229.587L315.104,233.895L316.205,233.994L315.708,235.881L319.454,242.039L321.134,243.229L321.054,244.288L324.327,247.629L325.142,248.026L325.534,248.886L325.063,250.506L326.923,253.15L329.438,255.529L329.674,256.983L339.158,266.987L342.854,272.001L346.6,275.43L346.313,277.902L345.762,278.066L345.238,279.121L345.396,280.077L347.779,283.305L352.261,286.993L352.627,288.803L351.685,290.746L352.941,292.982L352.627,293.673L354.015,295.646L353.622,295.909L355.379,297.291L358.783,301.203L359.885,306.23L364.708,309.975L364.784,312.207L365.701,313.356L366.409,316.834L368.242,318.442L369.265,318.344L369.737,320.869L370.366,320.607L371.389,320.934L371.334,321.591L372.2,322.017L371.938,323.819L374.059,325.755L374.112,326.803L374.741,327.229L373.273,328.343L373.981,330.112L373.142,332.503L373.692,335.09L374.898,336.302L375.841,338.757L376.418,339.019L376.104,340.196L376.916,341.031L376.916,341.031L372.648,341.745L372.648,341.745L370.781,343.924L368.289,344.859L365.487,347.35L365.487,347.35L363.931,349.53L363.931,350.775L363.931,350.775L365.487,353.578L358.966,353.739L358.966,353.739L356.313,351.472L353.368,350.443L350.762,350.046L348.22,352.556L347.214,352.364L344.148,350.619L340.807,349.946L339.643,349.919L337.467,350.661L336.79,349.34L335.071,348.658L335.071,348.658L334.145,349.251L332.17,352.955L332.17,352.955L331.235,354.2L327.188,354.2L323.763,351.397L320.96,349.841L318.945,350.024L318.299,352.335L318.403,354.731L318.042,355.484L317.293,355.847L315.838,354.895L314.232,354.477L312.318,354.731L309.242,352.64L308.075,352.4L308.075,352.4L306.341,351.052L306.341,351.052L305.702,350.265L305.702,350.265L303.572,350.525L303.572,350.525L302.218,350.476L298.268,349.202L298.268,349.202L296.656,348.491L294.688,346.294L293.027,345.772L292.684,346.205L292.684,346.205L291.748,346.627L291.748,346.627L288.459,347.205L287.644,346.957L287.331,347.55L286.577,347.674L285.761,346.278L285.761,346.278L285.582,345.456L285.582,345.456L284.434,344.92L284.434,344.92L283.968,344.637L283.968,344.637L283.98,342.689L283.98,342.689L284.073,342.021L284.073,342.021L283.111,341.213L281.657,341.539L279.244,341.352L279.244,341.352L278.379,341.399L277.191,342.651L277.191,342.651L275.733,342.791L275.229,343.309L275.229,343.309L274.537,343.777L272.227,342.013L272.227,342.013L271.567,340.32L273.082,339.058L273.082,339.058L274.824,338.3L274.824,338.3L277.173,335.577L277.278,334.214L276.7,333.692L275.725,333.687L274.363,334.518L274.363,334.518L273.314,334.782L273.314,334.782L271.605,334.552L270.135,332.821L268.015,332.388L266.037,330.882L263.586,331.47L262.471,332.402L261.8,333.913L261.125,334.008L258.156,333.005L256.57,334.777L254.488,336.079L254.488,336.079L252.359,336.446L252.359,336.446L250.321,337.265L250.321,337.265L249.422,336.937L249.422,336.937L249.085,336.463L249.149,333.096L249.149,333.096L247.375,329.797L247.375,329.797L245.334,329.28L245.334,329.28L243.119,329.355L241.624,330.297L241.624,330.297L239.252,331.979L238.787,332.978L239.063,335.671L239.78,337.658L239.359,339.456L237.32,340.248L236.881,341.191L236.212,341.553L233.889,340.402L230.861,340.496L229.415,342.368L227.236,343.302L223.188,340.188L222.571,336.71L222.571,336.71L223.188,329.29L222.565,325.865L224.122,324.619L223.811,317.146L227.236,309.051L227.547,305.003L225.599,304.294L224.814,301.917L227.58,298.787L227.944,297.895L230.004,297.194L230.797,295.015L229.528,293.47L229.148,292.12L226.909,292.287L226.059,291.5L223.779,290.877L220.199,290.757L215.9,287.071L213.217,286.747L211.404,285.293L209.112,284.273L205.481,285.671L204.2,284.761L202.847,282.833L204.591,279.328L204.901,274.949L203.349,275.501L202.603,275.363L201.946,275.998L201.319,275.85L201.438,273.831L203.591,271.981L204.131,270.759L202.813,267.261L202.82,266.348L203.637,265.305L203.438,263.559L202.791,262.363L203.379,260.841L205.636,260.091L207.431,258.03L210.043,257.461L210.735,256.96L211.732,253.001L210.917,248.976L209.476,247.389L207.467,247.003L205.28,245.972L205.197,243.276L204.317,242.674L201.105,243.016L198.017,241.491L196.765,239.9L196.464,238.474L196.062,230.974L194.641,229.006L193.907,228.914L192.687,230.049L191.991,229.091L190.599,228.501L189.116,228.697L186.751,229.507L185.538,230.911L185.018,230.625L183.104,228.452L181.749,228.239L180.559,227.048L180.248,225.082L180.792,223.96L181.042,221.737L182.132,220.819L180.165,219.942L179.599,219.982L178.192,221.286L176.511,223.677L174.081,223.839L172.44,223.01L171.933,222.074L172.047,219.828L171.056,220.137L170.877,219.063L171.5,217.195L169.942,215.949L169.008,210.655L164.338,210.655L164.338,208.788L165.583,207.853L160.855,203.445L160.855,203.445L161.847,202.275L164.889,200.2L165.995,199.968L168.247,200.58L171.946,199.3L174.924,197.526L178.333,198.05L179.931,199.241L181.429,198.835L183.117,199.125L184.252,198.184L186.337,198.188L188.218,197.17L190.254,197.063L192.221,197.887L193.466,198.955L195.036,198.802L197.25,199.639L199.466,201.052L204.761,197.851L207.688,196.827L209.128,197.137L210.286,198.259L211.791,198.354L214.063,197.851L216.721,198.52L218.674,197.208L224.45,197.499L226.985,196.106L227.6,196.463L228.314,198.253L230.642,200.696L232.77,199.78L234.562,199.589L235.379,199.133L236.67,197.354L242.949,199.191L244.726,198.755L251.161,200.193L254.118,199.734L257.092,197.3L259.722,197.403L260.425,197.025L263.346,194.067L267.203,191.624L268.49,189.518L270.25,188.37L274.009,184.685L276.168,180.092L275.941,178.648L276.981,175.509L276.455,166.447L277.016,165.705z"/>
			        <path id="KR-43" title="33000" class="land" d="M213.845,469.246L212.913,466.451L211.355,463.338L209.176,461.47L208.864,458.667L208.864,458.667L210.11,455.865L209.799,452.751L207.93,449.638L207.93,449.638L205.137,449.903L204.108,449.057L201.186,447.984L200.146,444.344L201.391,438.116L201.391,438.116L202.326,432.512L202.326,432.512L203.882,430.954L205.128,430.644L203.882,428.463L203.113,428.254L203.429,426.63L201.663,426.219L201.007,425.477L200.769,422.859L200.769,422.859L198.277,420.368L198.277,420.368L195.425,423.018L195.419,422.76L195.419,422.76L195.487,422.123L195.487,422.123L195.81,420.82L194.428,420.64L194.428,420.64L193.818,421.286L193.818,421.286L192.841,423.558L192.356,423.646L192.356,423.646L192.048,423.476L192.048,423.476L190.805,418.188L186.859,418.604L186.472,418.063L185.765,417.918L185.367,418.243L185.367,418.243L184.789,419.024L184.789,419.024L186.651,412.939L185.572,411.799L186.398,409.98L186.491,408.524L183.159,408.329L182.709,406.979L182.709,406.979L182.709,404.176L179.906,400.751L182.086,400.128L182.397,397.326L182.397,397.326L180.84,395.146L185.823,387.362L189.559,387.673L191.116,385.805L189.87,382.069L186.757,379.889L183.882,379.889L183.882,379.889L182.805,379.411L182.966,377.421L182.966,377.421L182.904,377.001L182.377,376.935L182.377,376.935L180.897,376.228L180.897,376.228L180.667,373.574L177.836,371.66L176.929,369.245L179.688,369.014L179.688,369.014L181.204,368.105L181.204,368.105L182.761,367.755L182.761,367.755L183.46,367.315L183.46,367.315L185.161,366.08L187.367,366.216L188.271,364.865L189.157,364.471L189.323,362.368L189.021,361.285L189.021,361.285L191.011,359.693L191.011,359.693L194.098,358.282L193.919,357.836L194.846,356.694L194.896,355.659L197.23,353.095L198.031,354.283L199.511,354.262L199.239,356.327L200.834,353.108L205.128,353.889L209.176,350.153L211.667,349.841L212.29,342.057L213.847,342.057L215.403,343.924L217.272,343.924L219.928,337.293L222.571,336.71L223.188,340.188L227.236,343.302L229.415,342.368L230.86,340.497L233.889,340.403L235.805,341.483L236.881,341.191L237.32,340.249L239.358,339.456L239.78,337.658L239.062,335.671L238.787,332.978L239.252,331.979L241.624,330.297L241.624,330.297L243.119,329.355L245.334,329.28L245.334,329.28L247.375,329.797L247.375,329.797L249.149,333.096L249.149,333.096L249.086,336.463L249.422,336.937L249.422,336.937L250.321,337.265L250.321,337.265L252.359,336.446L252.359,336.446L254.488,336.079L254.488,336.079L256.57,334.777L258.156,333.005L261.124,334.009L261.8,333.914L262.47,332.402L263.586,331.47L266.037,330.882L268.015,332.388L270.135,332.821L271.605,334.552L273.314,334.782L273.314,334.782L274.363,334.518L274.363,334.518L275.725,333.687L276.7,333.692L277.278,334.214L277.173,335.577L274.824,338.3L274.824,338.3L273.082,339.058L273.082,339.058L271.567,340.32L272.227,342.013L272.227,342.013L274.537,343.777L275.229,343.309L275.229,343.309L275.733,342.791L277.191,342.651L277.191,342.651L278.379,341.399L279.244,341.352L279.244,341.352L281.657,341.539L283.11,341.213L284.073,342.021L284.073,342.021L283.98,342.689L283.98,342.689L283.968,344.637L283.968,344.637L284.434,344.92L284.434,344.92L285.582,345.456L285.582,345.456L285.761,346.278L285.761,346.278L286.576,347.674L287.33,347.551L287.643,346.957L288.459,347.205L291.748,346.627L291.748,346.627L292.684,346.205L292.684,346.205L293.027,345.772L294.688,346.294L296.655,348.491L298.268,349.202L298.268,349.202L302.218,350.476L303.572,350.525L303.572,350.525L305.702,350.265L305.702,350.265L306.341,351.052L306.341,351.052L308.075,352.4L306.804,353.68L306.804,353.68L305.876,354.554L305.41,354.324L305.41,354.324L304.483,353.998L304.483,353.998L303.735,354.308L303.735,354.308L302.292,356.445L301.463,356.915L301.463,356.915L300.847,357.195L300.847,357.195L297.564,360.438L294.767,361.245L294.767,361.245L293.983,362.485L293.983,362.485L293.519,363.482L290.444,365.227L290.354,366.107L288.872,367.577L287.293,370.884L287.293,370.884L286.461,372.446L286.461,372.446L286.409,373.777L287.721,374.385L287.721,374.385L288.252,375.198L288.252,375.198L288.514,377.292L285.676,381.182L285.676,381.182L284.249,381.479L284.249,381.479L282.143,381.63L282.143,381.63L281.689,381.96L281.689,381.96L280.766,382.988L278.331,382.937L278.331,382.937L276.689,383.371L276.143,383.117L276.143,383.117L275.109,380.325L273.655,378.204L270.424,376.36L269.245,374.392L269.245,374.392L268.164,375.666L267.888,376.682L267.888,376.682L267.58,377.433L266.452,377.776L266.21,380.36L266.21,380.36L266.007,381.003L266.007,381.003L265.642,381.568L260.447,380.274L259.95,379.833L259.95,379.833L259.53,379.204L259.53,379.204L258.468,378.828L257.859,379.453L257.859,379.453L256.477,380.6L256.477,380.6L255.329,382.538L255.329,382.538L253.954,382.727L253.954,382.727L252.319,380.983L251.813,381.287L249.109,387.615L249.109,387.615L248.954,387.962L248.954,387.962L252.188,392.404L252.341,393.197L251.153,393.302L247.75,392.289L247.75,392.289L246.572,391.625L245.367,392.209L245.367,392.209L243.181,391.195L243.181,391.195L242.059,390.583L242.059,390.583L240.893,392.917L239.191,394.307L237.591,395.349L235.591,395.474L235.591,395.474L234.948,395.727L234.948,395.727L233.268,398.097L233.75,400.315L233.75,400.315L233.304,401.013L233.304,401.013L231.101,402.917L231.101,402.917L230.523,403.646L230.523,403.646L229.581,405.15L228.769,405.195L228.769,405.195L227.209,405.546L227.209,405.546L226.391,406.546L226.222,407.45L226.949,408.545L232.303,409.675L233.518,410.893L233.376,411.821L233.376,411.821L233.762,413.376L234.34,413.786L234.34,413.786L235.977,414.465L236.343,415.146L235.921,416.848L235.921,416.848L235.797,417.407L235.797,417.407L233.91,417.739L233.91,417.739L233.48,419.072L233.48,419.072L233.774,422.663L233.103,425.348L233.696,426.525L233.697,427.818L232.417,429.83L233.73,433.077L233.73,433.077L234.224,433.383L234.224,433.383L233.225,435.941L230.57,438.244L230.57,438.244L230.5,442.521L230.869,443.304L232.65,444.295L232.65,444.295L234.492,443.225L235.65,441.723L236.057,441.741L236.52,443.183L238.756,443.977L239.014,444.658L239.014,444.658L239.106,445.157L239.106,445.157L240.086,445.479L240.086,445.479L240.86,446.227L240.86,446.227L241.195,446.721L242.033,446.623L242.033,446.623L244.016,445.787L244.016,445.787L246.244,445L248.26,445.695L248.26,445.695L248.879,446.763L248.879,446.763L248.523,447.827L249.029,449.926L249.029,449.926L249.599,451.23L250.287,451.795L250.287,451.795L250.196,452.589L249.044,453.141L246.578,451.666L244.175,453.09L243.518,453.946L242.995,454.826L243.076,456.012L244.169,457.779L243.659,459.187L243.759,461.344L242.007,462.804L242.189,463.722L241.197,465.4L240.971,467.434L239.134,470.026L238.384,470.357L237.505,469.692L236.265,469.93L232.449,473.563L230.453,471.346L229.56,471.286L229.56,471.286L228.19,471.735L228.19,471.735L225.466,473.348L225.466,473.348L224.581,473.682L224.581,473.682L224.222,474.583L224.222,474.583L221.625,474.587L221.471,473.671L221.471,473.671L219.771,472.63L219.771,472.63L218.6,472.34L218.6,472.34L216.343,471.783L216.343,471.783L215.681,471.219L215.681,471.219L214.63,468.952z"/>
			        <path id="KR-44" title="34000" class="land" d="M92.285,433.004l-0.106,0.906l-1.309,-0.615l-0.472,0.68l-0.235,-1.393l1.073,-0.745l0.026,-1.328l0,0h0.656l0.209,1.685l0.943,0.713L92.285,433.004zM99.542,428.241l-0.733,0.778l1.153,0.583l1.572,0.161l-0.157,0.939l-1.415,-0.129l-0.184,-0.615l-1.651,-0.454l-1.624,0.032l-0.394,-0.583l-1.205,0.421l-0.655,-0.26l-0.026,-1.068l0.734,-0.551l1.44,0.486l1.075,0.906l-0.524,-1.425l0.943,-0.454l0,0l1.022,0.098l0.158,1.037L99.542,428.241zM93.804,411.571l0.262,0.326l1.153,-0.034l0.812,0.941l0.21,1.104l-0.524,0.355l-0.026,0.553l1.1,-0.325l-0.156,1.818l0.863,1.427l-0.995,1.427l0.786,0.195l0.708,1.427l0.864,0.13l-0.209,0.973l0.472,1.167l-1.285,1.005l0.576,1.361l-0.838,0.13l0.209,-0.455l-0.34,-0.452l-0.498,0.291l-0.158,-1.167h-1.206l0.367,-0.745l-1.913,-0.033l-0.052,0.584l-0.917,0.519l-0.498,-0.615l-0.419,0.065l-0.131,-1.006l-0.682,0.032l0.551,-1.881l-1.992,0.194l-0.445,-0.583l0.235,-0.649l-0.366,-0.973l0.759,-1.719l-1.363,0.389l0.105,-0.486l0.681,-0.292l0.288,-2.108l-0.052,-0.65l-0.603,-0.291l0.288,-0.909l-0.524,-0.195l0.315,-5.194l-1.441,-1.852l-0.209,-1.526l0.891,-0.846l0.053,-0.812l2.777,-2.112l0,0l0.42,-0.163l0.917,0.78l-0.052,1.138l0.787,0.617l-0.184,0.747l0.419,0.099l-0.053,1.136l-1.362,0.455l-0.156,0.521l1.467,0.682l0.34,1.754l-0.236,1.494l1.021,1.363l-0.104,0.584L93.804,411.571zM100.564,349.877l-2.804,0.294l0.289,-0.981l-0.603,-1.079l0.262,-0.72l0,0l2.358,0.393l0.524,0.817L100.564,349.877zM105.071,347.327l2.018,0.719l0,0l1.546,2.256l2.201,0.36l6.787,4.051l1.599,0.392l4.742,-0.163l0.367,0.785l7.494,2.024l0.288,0.425l-0.367,0.947l1.572,2.677l-0.314,0.424l0.419,0.784l0.367,0.555l0.288,-0.327l0.471,0.163l0.525,3.362l0.942,1.076l0.027,0.555l3.563,0.652l1.704,-0.783l2.776,-0.279l0.986,-0.056l0.827,-1.208l1.638,-0.809l7.535,1.758l0.832,-0.612l0.938,0.005l3.158,-1.162l3.004,-2.065l2.578,-0.084l2.982,1.423l1.335,1.794l1.945,1.582l5.085,0.697l0.907,2.414l2.832,1.915l0.229,2.654l1.48,0.707l0.527,0.066l0.063,0.42l-0.161,1.99l1.077,0.478h2.875l3.114,2.18l1.245,3.736l-1.557,1.869l-3.737,-0.312l-4.982,7.785l-2.438,0.202l-2.555,-0.941l-2.69,-1.614l-1.48,-1.615l-2.556,-0.807l-2.69,1.076l-0.403,1.75l1.076,2.018l0.539,2.017l0.269,3.095l-0.672,2.421l0.269,3.363l0.135,3.498v3.094l-1.076,2.421l0.134,2.018l1.883,2.557l2.691,1.479l1.345,3.901l0.269,2.825l-0.134,4.034l1.211,3.095l1.748,1.345l1.703,2.052l0.311,4.048l2.18,1.868l0.312,3.425l1.557,2.18l2.491,0.935l0.934,3.113h1.246l0.934,-2.18l0.623,-4.981l-0.312,-3.114h1.557l0.623,1.557v1.869l2.179,3.736l3.737,2.18l2.179,-2.803l3.345,-2.178l2.796,0.975l1.03,0.847l2.792,-0.266l1.869,3.113l0.311,3.114l-1.246,2.802l0.312,2.803l2.179,1.868l1.557,3.113l0.932,2.795l-0.309,0.329v2.48l-2.803,2.804l-1.557,-1.246l-2.538,-1.202l-1.884,0.998l-1.026,0.182l-0.158,2.202l-0.934,1.868l-3.113,0.622l-3.425,-0.311l-0.623,-2.803l-0.073,-2.18l-0.605,-0.162l-3.058,1.719h-1.245l-1.868,-4.358l-0.347,-2.769l-2.958,-5.093l-1.131,-1.624l-2.414,2.012l-4.359,-0.311l0.624,2.49l-5.294,0.312l-1.726,-1.726l-1.116,-0.164l-1.895,1.148l-2.295,0.234l-1.472,0.718l-2.546,-0.183l-0.506,-0.806l-0.025,-1.21l-2.43,-0.192l-0.312,-3.737l-2.189,-2.006l-1.264,0.379l-3.756,-2.265l-3.677,-0.668l-2.674,2.006l-2.005,0.668l-0.003,8.425l-7.162,3.427l-4.359,1.557l-1.479,-1.356l-1.304,0.557l-0.682,-0.327l-0.314,1.032l-1.074,1.128l-4.271,-1.063l-1.127,0.612l-0.733,-0.742l0.419,-1.064l-0.472,-1.063l0.682,-0.064l0.078,-0.42l-2.253,-2.58l-1.048,0.096l-0.288,-2.807l-1.049,0.192l0.682,-1.032l0.732,0.419l1.101,-0.807l-0.079,-0.517l-1.179,0.319l0.026,-0.835l-1.048,-0.484l-0.813,0.71l-1.336,-2.939l-2.542,-2.196l-1.389,1.39l-0.131,-0.905l-0.785,-0.936l-2.621,-0.938l-1.179,0.323l-0.288,2.39l-1.075,-0.968l0.027,-2.746l0.812,0.452l1.546,-0.227l0.759,-0.97l-0.184,-2.229l1.102,-1.584l0.392,-0.033l-0.891,-4.494l0.655,-0.776l0.314,-1.747l0.708,-0.129l0.053,-0.484l-0.577,-0.972l-0.733,-0.29l0.497,-0.324l-1.179,-2.234l-0.917,0.131l-0.42,-1.619l-1.231,-1.585l0.445,-0.52l0.838,0.421l0.629,-0.81l2.227,-0.777l0.289,-0.68l0.917,-0.552l2.594,0.228l-3.249,-0.681l-4.717,-3.272l-1.781,-0.032l0.418,-3.208l0.917,-1.913l0.997,-0.228l1.388,-1.426h1.258l0.654,-1.199l0.682,0.097l0.184,-0.389l1.493,0.097l0.682,-2.757l1.258,0.714l1.441,-0.261l0.997,-1.232l-2.228,0.779l-1.441,-0.909l-0.498,0.487l-0.498,-0.585l-0.105,0.746l-2.096,1.363l-0.314,1.168l-0.787,0.064l-0.314,1.396l-2.62,1.329l0.263,-1.2l-1.232,-1.297l0.105,-1.784l-0.655,-1.006l0.235,-3.407l0.708,-0.261l0.263,-0.973l1.048,-0.876l2.148,0.811l1.284,1.526l0.76,-0.099l-1.65,-1.558l-1.755,-0.681l-0.734,-0.748l-1.494,1.267l-0.234,-1.006l-2.123,-1.884l0.654,-1.688l-0.733,-3.021l-0.996,-1.202l-3.458,-1.397l-0.551,-0.943l-3.616,-0.584l-0.682,-0.651l-2.332,1.399l-1.573,1.526l-0.576,1.56l-0.603,-0.584l-1.572,1.852l-0.209,-0.909l-0.813,-0.813l0.656,-1.04l-0.105,-1.885l1.047,-0.748l-0.131,-3.153l-1.073,-2.31l-0.551,-0.422L83.9,393.7l-0.917,-0.227l-0.079,-0.749l0.394,-0.358l-0.525,-0.326l-0.105,-0.715l0.105,-0.685l1.022,-0.683l-0.209,-1.433l0.289,-0.78l0.471,0.13l0.34,-0.423l-0.394,-0.749l-0.864,0.065l-0.996,1.465l-2.097,-0.098l-0.183,0.976l0.604,0.489l-0.105,0.358l-0.76,0.228l0.131,0.585L77.716,391l0.132,0.652l-0.943,0.227l0.184,0.456l-0.445,0.976l-0.787,0.26l-0.315,-0.749l-0.89,0.391l-1.914,-0.292l-0.603,-2.017l0.341,-0.293l-0.551,-0.554l0.262,-0.422l1.18,-0.293l-0.288,-0.391l0.943,-0.781l1.284,0.357l1.467,1.107l0.812,0.065l0.97,-0.716l0.576,-1.205l-0.891,-0.651l-1.048,0.651l0.052,-0.651l1.207,-1.691l-1.232,0.585l-1.913,-1.074l1.022,-1.335l-0.865,0.195l-0.314,-0.423l-1.493,-0.065l-0.865,0.553l-1.546,-0.846l0.131,0.912l0.864,0.75l0.157,2.018l-2.672,2.669h-0.419l0.131,-0.782l0.524,-0.292l-0.34,-1.172l1.127,-1.627l-0.393,-0.619l0.314,-0.423l-0.157,-0.293l-0.708,0.293l-0.34,-0.554l0.235,-0.684l-0.393,-0.065l0.184,-0.488l-0.813,-0.456l-0.079,-0.554l1.808,-0.358l-0.026,-1.271l0.419,0.521l1.049,-0.847l0.418,-1.565h-0.497l-0.237,-0.651l0.682,-0.39l-0.027,-0.554l0.656,-0.065l0.183,-1.174l-1.284,-1.206l0.917,-0.033l-0.577,-1.043l0.628,0.293l0.472,-0.75l0.079,1.076l1.022,0.064l-0.498,1.304l0.629,0.586l-0.184,1.825l0.236,0.195l0.445,-0.717l1.284,3.323l0.629,0.359l-0.525,-2.64l-0.838,-0.489l-0.262,-1.205l1.1,-0.097l-1.415,-1.565l1.127,-0.782l0.943,-1.956l-0.996,0.065l0.053,-1.207h-0.655l-0.079,-0.489l0.891,-0.685l-0.523,-0.685l-0.917,-0.163l0.104,-0.359l0.996,-0.293l0.446,0.522l0.419,-0.098l0.288,-0.554l-0.288,-0.327l0.681,-0.391l-0.183,-0.979l0.917,0.784l0.549,-0.816l1.546,-0.392l0.262,-0.685l0.499,0.261l0.969,-0.359l-0.445,0.686l2.673,1.305l1.022,-0.228l-0.368,-1.077l0.838,-1.306l-0.288,-3.688l-0.76,-1.437l0.419,-0.718h0.865l0.524,-0.98l0.523,-0.098l0.262,0.752l-0.445,0.816l-1.021,0.261l0.812,1.045l0.629,-0.359l0.367,0.26l-0.943,1.306v3.231l0.655,0.457l0.131,0.75l0.865,0.261l0.183,1.599h0.97l-0.131,0.555l-1.231,0.032l-0.394,0.359l-0.026,0.815l-0.969,1.206l-0.031,1.012l-0.625,0.619l-0.079,1.174l2.096,0.456l-0.157,0.684l-1.912,0.946l-1.128,-0.032l-0.235,0.75l0.681,0.423l-0.209,1.303l0.498,0.62l0.524,-0.521l-0.13,-0.587l0.367,-0.259l0.262,0.521l0.314,-0.198l-0.314,-0.616l0.34,-0.424l0.76,0.424l0.864,-0.88l0.525,0.586l0.602,-0.032l0.079,-0.392l-0.943,-0.75l-0.105,-0.75l0.393,-0.424l-0.969,-0.75l1.126,-2.674l0.759,0.458l0.839,-0.164l-0.419,1.696l1.257,1.727l0.813,0.099l-0.891,-1.858l1.441,-1.239l0.026,-1.337l-0.629,-0.88l1.231,-0.717l1.939,0.26l-0.157,-1.533l0.707,0.293l0.105,-0.75l0.969,0.392l0.289,-0.489l1.101,-0.065l0.131,-0.358l-0.446,-0.556l-1.704,-0.26l0.21,-0.784l-0.551,-0.359l-0.078,-0.293l0.863,0.196l0.524,-0.523l-0.026,-1.501l-0.917,-0.425l0.051,0.458l-0.969,0.098l-0.759,0.783l-0.629,-0.554l-0.235,-1.273l-1.179,-0.261l-0.943,0.914l-0.262,-0.26l0.445,-1.078l-0.918,-0.163l-0.182,-1.143l-1.442,0.164l0.209,-1.077h2.464l0.707,1.109l0.446,-0.979h1.101l0.105,-0.36l-0.131,-0.327l-0.864,0.163l0.104,-0.718l-0.55,-0.522l-0.813,0.491l-0.183,-0.491l-2.961,-0.228l-0.314,-1.83l0.708,0.359l1.65,-0.882l0.314,-0.785l0.813,0.523l1.755,-0.359l0.341,-0.686l0.366,0.49l3.59,-0.099l2.673,1.34l1.258,-0.653l-0.997,-1.895l0.419,0.097l2.175,-2.516l-0.525,-0.556l0.708,-1.373h0.498L105.071,347.327z"/>
			        <path id="KR-45" title="35000" class="land" d="M128.549,470.012L129.853,469.455L131.332,470.812L135.691,469.255L142.853,465.828L142.856,457.403L144.861,456.735L147.535,454.729L151.212,455.397L154.968,457.662L156.232,457.283L158.421,459.289L158.733,463.026L161.163,463.219L161.188,464.429L161.694,465.234L164.24,465.417L165.712,464.699L168.008,464.465L169.903,463.316L171.019,463.48L172.745,465.206L178.039,464.895L177.416,462.404L181.775,462.715L181.775,462.715L184.188,460.703L185.32,462.327L185.32,462.327L188.279,467.42L188.625,470.188L190.494,474.547L191.739,474.547L191.739,474.547L194.797,472.828L194.797,472.828L195.402,472.99L195.402,472.99L195.475,475.17L195.475,475.17L196.098,477.973L199.523,478.283L202.637,477.661L203.571,475.793L203.571,475.793L203.729,473.592L204.754,473.409L204.754,473.409L206.638,472.411L209.176,473.613L210.733,474.859L213.536,472.056L213.536,469.575L213.536,469.575L213.845,469.246L214.63,468.952L215.681,471.219L215.681,471.219L216.343,471.783L216.343,471.783L218.6,472.34L218.6,472.34L219.771,472.63L219.771,472.63L221.471,473.671L221.471,473.671L221.625,474.587L224.222,474.583L224.222,474.583L224.581,473.682L224.581,473.682L225.466,473.348L225.466,473.348L228.19,471.735L228.19,471.735L229.56,471.286L229.56,471.286L230.453,471.346L232.449,473.563L235.184,471L235.184,471L238.66,476.653L239.89,479.955L239.618,482.716L238.605,484.957L238.605,484.957L236.286,486.468L234.78,489.147L234.243,491.08L232.922,491.317L231.144,492.961L229.686,492.97L229.686,492.97L227.864,494.116L227.864,494.116L226.561,494.172L226.561,494.172L225.852,493.678L225.852,493.678L225.41,493.514L225.203,494.15L225.203,494.15L225.022,494.732L225.022,494.732L224.354,495.937L224.354,495.937L223.549,498.218L220.289,501.803L218.62,502.945L217.84,507.756L217.84,507.756L217.685,509.669L216.794,510.465L216.794,510.465L215.854,511.912L213.953,516.844L213.953,516.844L213.169,521.57L213.169,521.57L211.583,524.844L211.583,524.844L211.753,527.155L211.753,527.155L213.826,527.823L214.521,528.524L214.521,528.524L214.441,530.378L214.942,531.425L214.942,531.425L216.209,533.691L216.209,533.691L215.524,537.025L215.524,537.025L216.214,538.949L216.214,538.949L217.843,539.376L217.843,539.376L217.942,539.92L217.942,539.92L217.388,543.376L213.693,546.935L212.876,548.918L212.539,550.075L213.089,552.938L210.877,555.237L210.877,555.237L210.648,555.441L210.648,555.441L207.582,552.802L204.285,550.988L204.285,550.988L203.251,550.071L199.751,548.915L199.751,548.915L197.759,549.023L197.759,549.023L196.008,550.006L193.063,553.792L192.44,554.233L191.316,554.254L191.316,554.254L188.129,553.891L185.751,554.587L185.751,554.587L179.61,554.606L178.486,553.952L178.486,553.952L177.049,552.582L175.122,553.702L175.122,553.702L171.974,552.351L170.676,553.184L170.676,553.184L169.714,554.081L169.714,554.081L168.293,555.021L166.687,555.167L166.687,555.167L164.593,554.629L164.593,554.629L162.007,552.657L162.425,549.054L161.417,546.183L161.417,546.183L159.83,546.197L159.342,545.516L159.255,544.582L160.401,543.208L160.401,543.208L160.558,540.705L159.945,538.805L158.599,537.767L156.792,537.372L156.088,537.689L155.109,539.473L154.112,540.113L153.581,542.19L153.581,542.19L153.442,543.209L153.442,543.209L152.421,543.903L150.453,543.335L150.453,543.335L149.42,542.44L149.42,542.44L146.903,537.68L145.808,536.552L142.868,534.696L139.851,534.091L138.286,535.952L137.204,535.737L137.204,535.737L135.68,535.384L135.68,535.384L133.418,536.362L132.809,537.17L132.626,538.348L132.626,538.348L132.775,541.438L132.189,542.112L132.189,542.112L130.742,543.057L130.589,543.738L130.589,543.738L130.85,544.509L130.85,544.509L130.991,545.465L130.226,547.474L127.819,548.69L127.819,548.69L124.685,549.652L123.158,551.145L123.158,551.145L121.088,551.853L120.125,551.426L120.125,551.426L119.015,551.186L118.031,551.538L116.583,553.078L112.242,553.311L112.242,553.311L111.867,551.612L110.159,551.612L108.913,547.566L107.044,545.386L106.889,542.432L106.11,539.781L104.242,538.224L104.242,538.224L102.374,537.602L102.374,537.602L100.434,537.42L100.459,537.004L100.014,536.878L99.281,537.313L98.547,537.101L101.848,531.496L102.713,528.933L103.342,528.677L103.656,527.299L103.97,527.203L104.338,528.324L105.02,528.581L105.49,528.133L104.993,527.971L105.254,527.01L107.036,525.856L108.032,525.729L109.237,526.786L109.971,525.6L111.465,524.703L114.006,525.023L114.241,526.273L114.478,525.279L115.315,524.414L115.761,522.715L116.312,522.875L116.26,521.654L116.757,522.009L117.7,521.239L119.298,521.72L121.264,523.708L121.762,524.767L121.84,524.062L121.107,522.394L121.447,521.497L120.478,520.918L120.635,520.245L121.08,520.63L121.631,519.86L120.242,519.892L120.242,519.379L119.561,518.769L118.88,518.865L118.198,518.191L117.91,519.059L117.203,519.25L116.443,518.834L115.657,519.764L114.976,519.731L115.054,519.25L114.425,518.802L114.006,519.571L112.25,519.315L109.919,519.86L109.106,519.54L107.953,520.63L107.036,520.565L106.695,519.571L106.12,520.63L104.416,519.892L103.316,517.871L102.084,518.449L101.351,516.813L101.743,515.434L102.399,514.92L102.293,514.438L101.561,514.374L101.141,513.893L102.006,513.57L102.031,513.025L103.106,513.122L103.97,512.03L105.438,511.453L108.766,507.888L110.6,506.699L111.753,507.311L113.299,505.64L114.241,505.189L115.998,502.299L117.307,500.948L117.176,497.379L116.599,496.64L117.648,495.031L119.508,495.964L124.12,495.257L128.601,496.447L130.696,498.184L131.194,500.402L132.033,501.206L132.714,500.563L131.483,500.208L131.509,498.665L132.085,497.926L131.404,495.031L127.395,492.909L124.12,490.335L122.652,490.045L124.094,488.564L127.291,487.341L130.907,487.984L131.457,487.567L132.583,487.567L133.5,486.44L133.16,485.475L133.579,484.347L135.361,483.8L136.487,482.931L136.252,482.479L134.862,482.994L133.814,482.737L132.321,483.06L130.67,484.702L127.867,484.412L125.718,485.185L122.469,484.187L121.107,485.41L115.944,485.12L115.63,481.352L116.128,478.581L114.059,477.905L111.595,478.098L111.569,477.002L109.683,475.521L110.417,474.617L113.167,474.456L113.823,474.844L115.315,474.264L116.26,474.425L116.468,475.262L117.176,474.425L117.78,474.746L122.888,473.619L124.539,472.394L127.421,473.521L128.521,472.845L129.125,471.652L129.439,470.329z"/>
			        <path id="KR-46" title="36000" class="land" d="M66.554,668.835l0.368,1.2l-0.603,-0.79l-1.231,-0.379l-0.682,1.199l-0.445,-0.41l0.236,-1.199l-0.419,0.347l-0.603,-0.283l0.472,1.041l-0.445,0.537l-0.472,-1.105l-0.472,0.221l-0.55,-0.473l-0.419,0.347l-1.022,-0.284l0.446,-0.567l-0.262,-0.537l-0.944,0.221l0.314,-0.852l0.341,-0.254l0.394,0.284l0.654,-0.758l-1.021,-0.313l0.156,-0.38l0.629,0.38l0.393,-0.38l-0.418,-0.379l0.865,-0.316l1.284,1.674l2.542,-0.38l0.786,-0.504l-0.21,1.578l0.708,1.104L66.554,668.835zM94.014,645.225l-0.734,-0.474l0.052,-0.412l0.838,-0.253l-0.472,-1.14l-0.865,-0.317l-0.759,-1.266l-0.787,-0.128l0.183,-0.537l-0.785,-0.602l-0.079,-0.634l-0.917,0.318l0.629,-1.109l-1.441,0.349l-0.158,0.665l-0.838,-0.223l-1.337,-1.52l0.761,-0.664l-0.733,-1.079l-0.997,-0.093V635.6l-3.17,-1.236l-1.598,0.033l-0.289,0.475l0.551,0.349l-0.394,1.648l0.996,0.22v0.317l-1.493,2.913l-0.551,-0.031l-0.288,-0.634l-0.079,1.204l-0.628,-0.19l-0.604,0.603l1.101,1.201l-1.887,0.158l-0.367,1.044l0.734,0.824l-1.127,0.538l-0.498,-0.475l-0.026,-0.696l0.471,-0.887l-0.445,-0.221l-1.572,2.183l0.209,0.381l-0.367,0.79l-2.226,0.791l-0.524,0.759l-2.49,1.33l0.21,0.696l0.733,0.158v0.854l-0.655,-0.569l-1.127,0.443l-1.074,1.044l0.131,0.632l-0.786,1.423l2.698,4.553h0.891l0.393,-0.824l1.049,0.033l0.289,0.791l-1.022,0.44l0.392,0.602l-0.943,1.231h1.651l-0.131,-0.727l0.761,-0.221l0.917,1.611l1.31,-0.222l0.943,0.285l0.105,-0.506l2.541,-0.474l-0.655,-1.264l1.23,0.536l0.918,-0.884l0.603,0.663l0.891,-1.201l1.624,0.128l0.498,-0.603l-0.812,-0.314l0.445,-1.202l1.152,0.095l-0.025,0.696h0.367l1.571,-0.822l-0.812,-0.98l0.891,-0.379l0.104,0.601l0.707,0.096l-0.367,-1.202l1.153,0.854l-0.236,-1.804l1.389,1.74l-0.603,0.157l0.237,0.569l0.366,0.348l0.865,-0.316l-0.026,-1.675l1.179,-0.886l0.498,-1.392l1.126,-0.885l-0.708,-1.645l0.551,-0.823l0.603,-0.032l0.157,-0.822l-1.205,-0.349l0.025,-0.854l1.495,-0.411l0.576,0.854l0.315,-0.41l-0.524,-0.981L94.014,645.225zM52.432,619.112l0.209,-0.506l-1.021,-0.699l0.131,-0.35l0.917,0.19l-1.258,-1.905l0.053,-1.461l1.127,0.064l0.21,-0.478l2.882,0.224l0.183,-0.666l0.629,0.19l0.341,-1.334l1.153,-0.159l0.209,-1.461l-0.472,-1.367l-0.34,-0.094l-0.183,0.445l-0.629,-0.224L56.519,610l-0.813,-0.285l-0.445,0.413l0.052,0.666l-0.682,0.287l0.105,0.539l-1.231,-0.254l0.209,0.635l-1.206,0.73l-1.206,0.254l-0.969,-0.158l-0.053,-0.572l-1.022,-0.126l-0.445,0.316l-0.288,-0.316l-0.157,0.952l0.576,0.253l-0.813,0.383l-0.131,-0.541l-0.393,0.763l0.576,0.698l-0.445,0.128v1.048l0.393,-0.159l-0.707,1.079l0.025,1.175l0.603,-0.159l-0.131,0.665l0.734,0.16l0.314,0.698l1.336,0.443l0.708,-0.19L52.432,619.112zM129.989,666.721l0.472,-0.096l0.471,-0.916l-0.628,-0.758l-1.441,0.031l-0.027,-1.01l-1.126,-1.454l0.026,-0.884l-0.682,-0.41l0.079,-2.813l-1.075,-1.202l-0.655,-0.095l-0.996,-1.199l-1.31,-0.096l-0.42,-0.442l-3.091,1.074l-0.97,0.886l-0.261,0.886l0.576,1.168l-0.367,0.41l0.367,2.021l-0.367,0.632l0.707,0.665l-0.498,0.883l1.965,0.412l0.524,0.915l0.655,0.094l0.445,0.79l-0.339,0.38l1.545,1.419l1.546,-0.599l2.489,1.264l-0.498,-1.77l0.314,-0.314l1.18,1.483l1.231,-0.095l0.76,0.632l0.786,-0.032l-0.471,-0.884l-0.76,-0.379L129.989,666.721zM59.349,621.811l-0.314,-0.604l-0.865,0.159l-1.467,-1.428l-1.258,-0.316l-0.471,-0.73l-0.053,-1.396l-0.446,-0.255l-0.157,1.81l-1.231,-0.063l0.261,1.396l-0.366,0.603l-0.97,-0.57l0.262,-0.604l-2.095,0.444l-0.21,2.951l0.603,1.649l0.733,-0.287l-0.078,-0.57l0.471,0.063l0.289,0.667l-0.34,0.443l0.838,0.508v-0.476l0.733,0.095l0.027,-0.666l0.524,0.031l0.288,0.444l-0.524,0.604l0.13,0.506l0.97,0.317l1.494,-0.666l0.026,-1.078l1.493,-1.015l0.157,-1.047l1.074,0.285l0.132,-1.204H59.349zM122.129,681.326l0.549,-0.724l-1.624,-1.576l-1.729,-0.569l-0.655,1.545l-0.891,-0.094l0.786,0.346l-0.576,0.411l0.576,0.409l0.446,-0.472l0.576,1.355l-1.127,0.945l-0.471,1.261l-0.471,-0.095l-0.236,0.503l0.55,0.475l-0.367,0.63l0.655,0.504l0.052,1.135l1.048,-1.009l0.315,0.221l-0.131,1.607l0.997,0.471l0.89,-1.038l-0.366,-0.663l0.602,-0.566l-0.367,-1.386l0.289,-0.222l0.813,0.6l0.262,-1.071l-0.419,-0.284l-0.891,0.251l-0.052,-1.417l-1.153,-0.378l0.131,-0.852L122.129,681.326zM116.181,676.754l-0.786,-0.408l0.026,-0.601l-1.362,-0.348l-0.76,0.348l-0.628,-0.536l-0.524,0.726l-0.472,-1.388l-1.415,0.063l0.708,0.472l0.053,0.537l0.472,0.063v0.599l-0.891,0.096l-0.263,0.756l0.314,0.222l0.289,-0.537l0.367,0.315l-0.472,0.632l-0.655,0.031l0.551,0.315l-0.604,0.599l0.445,0.347l-0.917,0.41l1.598,0.41l-0.053,1.166l2.568,0.536l-1.336,-1.544l0.314,-0.38l1.677,-0.125l-0.104,0.914l1.624,0.189l0.262,-0.222l-0.236,-0.724l-0.996,-1.198h1.809l0.262,-0.632l-0.577,-0.283L116.181,676.754zM115.63,682.84l-0.367,-0.535l-2.306,-0.411l-0.655,0.441l0.053,0.568l-0.393,-0.252l-0.105,-0.852l-1.389,0.284l-0.027,-0.725l-1.519,-0.884l-1.598,1.292l-0.577,0.032l-0.027,0.567l-1.074,0.599l0.472,0.851l-0.551,0.727l0.524,0.282l-0.524,0.599l0.839,1.954l0.629,-0.441l0.759,0.505l3.301,-1.607l0.394,-1.04l0.969,-0.031l-0.236,-0.504l0.655,-0.41l-0.183,-0.63l0.786,0.156l0.341,-0.756l1.152,2.019l0.054,-1.672l1.231,1.387l0.708,-0.945l-0.237,-0.914L115.63,682.84zM59.873,634.11l-0.445,0.539l0.104,0.728l0.603,0.508l-0.262,1.172l0.97,-0.126l-0.184,-0.855l0.577,0.095l0.158,-0.538l0.603,0.98l0.759,-0.569l0.603,0.539l-0.079,-0.349l0.524,-0.126l-0.184,-0.476l0.55,-0.697l-0.419,-1.109l-0.708,0.634l0.236,-1.996l-1.44,0.444l-0.315,-0.35l0.21,-0.602l-0.472,0.285L61,631.639l0.026,-0.918l0.655,-0.349l0.105,-0.857l-1.048,0.253l0.157,-0.791l-0.471,0.349l-0.943,-0.381l-0.446,0.476l0.603,1.428l-0.55,1.298l0.314,0.57l-0.289,0.667l0.813,-0.444l0.601,0.571l-0.261,0.696L59.873,634.11zM83.926,602.819l-0.341,-1.018l-0.236,1.335l-0.523,0.479l-2.07,-0.383l-0.734,-0.509l-0.471,1.812l1.231,0.096l1.206,0.826l0.865,0.095l1.571,-1.875l1.337,0.064l0.34,0.412l1.467,-0.126l0.368,0.857l0.444,-0.604l0.839,0.031l0.628,0.731l-0.052,0.541l0.708,-0.287l0.104,0.922l-0.472,0.096l-0.235,0.763l-0.996,0.222l0.445,0.668l1.756,0.539l0.183,-0.952l0.314,0.413l1.18,-0.636l-0.445,-1.939l0.786,-0.159l-0.289,-1.589l-1.073,0.446l-0.42,-0.764l0.551,-0.19l-0.104,-0.317l-1.939,-0.096l-1.179,0.413l-0.969,-0.826l1.021,-0.478l-1.074,-0.73l0.367,-0.477l0.786,0.286l0.053,-1.241l0.681,0.541l0.367,-0.731l0.577,-0.159l0.576,0.858l0.209,-0.35l-0.026,-0.986l-1.048,-0.35l-0.393,-0.891l-1.231,-0.287l-0.289,0.542l-0.734,-0.063l-0.654,-1.399l-0.656,-0.255l-1.571,1.049l-0.131,0.319l1.309,0.985l0.892,1.654l-1.023,0.636l-0.654,-0.668l-0.524,0.063l-0.209,1.622l0.707,0.636l-0.289,0.571L83.926,602.819zM69.227,619.843l0.838,-1.334l1.415,-0.126l-0.315,0.729l0.813,0.412l0.131,1.874l0.76,-0.445l1.126,0.571l0.891,-0.697l-0.157,-1.206l0.445,-0.572l-0.628,-2.411l-1.258,-0.795l0.079,-0.856l-1.781,0.667l-0.997,-0.763l-0.708,-1.46l-1.729,0.538l-1.808,-0.92l0.052,0.89l-0.393,0.317h-0.473v-0.571l-0.811,0.284l-0.63,-0.252l0.263,0.412l0.995,0.159l0.446,1.428l-0.708,0.509l-0.394,1.333l0.236,0.285l1.048,-1.079l0.997,-0.126l0.104,1.015l0.655,-0.285l-0.367,1.872l1.179,-0.158l-0.13,0.412L69.227,619.843zM77.009,628.088l-1.52,0.54l-0.183,-0.697l0.498,-0.824l-0.603,-0.73l-0.629,0.127v-0.791l-0.995,-0.065l-0.21,-0.665l-0.603,-0.222l-0.97,0.316l-0.629,1.554l-0.786,-0.57l-0.314,0.952l-1.179,0.095l0.262,1.015l0.996,-0.634l0.576,0.729l-0.445,1.204l-0.603,0.412l0.445,0.604l-0.367,0.76l0.629,0.254l0.786,-0.635l1.258,0.063l-0.053,-0.665l0.524,-0.285h0.97l0.21,0.603l0.498,-0.033l0.629,-1.044l1.52,-0.159l0.368,-0.412L77.009,628.088zM73.733,577.703l-0.471,1.881l0.577,-0.796l0.131,0.7l0.969,-0.287l-0.549,0.765l1.886,0.383l-0.026,-0.478l0.445,-0.128l0.839,1.052l1.78,-0.159l0.97,0.605l-0.419,1.655l0.917,0.191l0.865,1.593l0.838,0.352l0.577,-0.225l0.969,-1.911l-1.152,-0.732l-0.394,-2.421l-1.414,-0.989l-0.052,-1.209l0.55,-1.53l-0.524,-0.64l-1.388,0.894l-0.394,-1.052l-0.734,-0.224l-1.231,0.574l0.105,-0.669l-1.101,-0.574l-0.367,0.351l-0.681,-0.127l-0.315,0.7l-0.838,-0.159l-1.127,0.829l-0.079,1.084L73.733,577.703zM65.768,603.327l-0.629,0.954l-1.572,0.286l1.678,2.542l1.362,1.303l0.523,1.017l-0.156,1.05l2.2,-0.351l0.498,-1.398l-0.917,-1.651l0.681,-0.541l0.105,-0.604l1.126,0.509l1.598,-1.239l-1.022,-1.081l-0.708,-0.031l-0.026,-0.795l0.551,-0.317l1.284,0.38l0.603,-0.793l-0.394,-0.511l-0.445,0.224l-0.551,-1.525l-0.471,0.764l-0.681,-0.604l-0.707,0.126l-0.813,-0.412l-0.577,0.381l0.551,0.795l-0.551,0.444l0.157,0.541l0.891,0.73l-0.498,0.923l-2.123,-0.636l-0.34,-0.636L65.768,603.327zM67.288,587.102l0.708,0.509l1.44,-0.031l0.236,-0.478l0.944,-0.127l0.759,0.445l1.834,-0.031l0.708,-1.146l-0.524,-0.192l0.446,-0.54l-0.367,-0.415l-2.83,-0.987l-0.576,0.033l-0.236,0.986l-0.864,-0.063l-0.655,1.529l-0.55,-0.319L67.288,587.102zM56.44,602.405l-0.524,0.382l0.603,0.191l0.445,-0.35l0.577,0.444l0.366,-0.508l0.97,0.793l0.472,-0.603l1.755,0.571l1.048,1.845l0.367,-0.382l-0.55,-1.399l0.76,-0.222l0.209,0.762l1.44,-0.445l-0.524,-0.57l0.184,-0.224l1.966,0.096l-0.604,-1.431l1.914,-0.922l0.052,-0.572l-1.021,-0.127l-0.471,-0.796l1.518,-1.399l-1.414,-0.224l-0.079,-0.413l0.655,-0.285l0.131,-0.509l-1.231,0.286l-0.315,-0.51l0.42,-0.795l-2.097,-0.859l0.393,2.164l-0.576,0.954l-1.021,0.19l-0.419,-1.112l-0.55,0.031l0.313,0.478l-0.419,0.699l-1.101,0.159l-0.708,-0.509l-0.052,0.954l-0.89,1.622l-0.525,0.35l-0.497,-0.223l0.288,0.764l-0.524,0.729l-0.996,-0.286l-1.125,0.32l-0.027,0.476l1.101,-0.316L56.44,602.405zM62.676,580.221l0.865,-0.382l-0.053,0.894l0.655,0.125l-0.419,-1.369l1.573,-0.256l-0.262,1.147l0.262,0.446l0.811,0.064l0.105,0.382l0.813,-0.127l0.079,0.573l0.549,0.063l-0.051,-0.51h0.471l-0.393,-1.052l1.52,0.097l-0.681,-0.702l-0.131,-0.827l0.603,0.317l0.628,-0.542l-0.157,-0.478l-1.335,-0.51l-0.289,-0.767l0.315,-1.497l0.55,-0.383l0.628,0.352l-0.184,-1.467l0.499,-1.628l0.366,-0.541l1.729,-0.193l0.262,-0.636l1.468,-0.288l-1.284,-0.224l-2.777,0.733l-0.577,-0.285l0.236,0.541l-0.341,0.543l-2.804,2.966l-1.336,0.67l-1.86,-0.098l0.183,1.085l-0.865,1.18l1.572,0.924l-0.315,0.861l-1.677,-0.255v0.541l0.498,-0.159L62.676,580.221zM6.552,622l-0.839,0.381l-0.314,1.015H4.717l-0.654,-0.729l1.283,-1.048l-2.489,0.128l-0.603,0.443l0.053,1.237l-1.075,1.017l-0.026,1.236l-0.97,0.665l0.235,0.73l0.839,0.284l-0.053,0.316l-1.179,0.285l0.943,1.65l1.572,0.568l-0.079,-1.679l0.603,-0.158l0.027,-0.444l0.995,-0.094l-0.55,-1.587h1.231l0.314,-0.285l0.34,-0.19l0.236,-2.061l0.97,-0.509l0.34,0.571l0.55,-0.697l-0.235,-0.762l-0.498,0.063L6.552,622zM144.846,679.94l-0.813,0.504l-0.394,-0.157l0.42,-0.347l0.079,-0.853l-0.787,-0.882l0.787,-0.441l-0.079,-0.758l-1.572,0.031l-0.315,-0.567l-0.68,0.063l-0.289,0.567l-0.891,0.221l-0.183,0.821l-1.179,0.313l0.472,0.442l-0.917,1.103l0.472,0.979l-0.786,-0.158l-0.209,0.504l0.34,0.695l0.445,-0.506l0.367,0.348l-0.996,0.882l0.576,0.189l-0.21,0.505l0.341,0.692l0.314,-1.292l0.865,-0.473l1.179,1.261l-0.079,0.598l1.782,-0.692l0.786,0.599l1.022,-0.913l0.603,-2.522L144.846,679.94zM224.761,599.671l0.865,0.605l0.838,-0.034l-0.131,-3.434l-1.703,-1.686l-2.699,-0.064l0.262,-1.718l-0.786,-0.636l-1.441,1.559l-0.131,0.636l-0.995,0.383l0.053,2.004l5.345,1.208l0.497,0.699l0.157,-1.877l-0.445,-0.285v-0.541l0.942,-0.35l0.789,1.533l0.153,2.377l-1.256,-0.315L224.761,599.671zM224.525,633.731l0.498,0.632l0.997,-0.157l0.891,0.539l1.546,-0.603l0.157,-0.855l-1.86,-1.236l0.393,-0.412l-0.078,-1.743l0.838,-0.348l-0.183,-2.886l0.786,-0.286l-0.052,-0.443l-1.022,0.127l-0.184,-0.507l0.733,-0.223l-0.576,-0.063l-0.235,-0.634l-0.734,0.317l-0.786,-1.237l0.445,-0.698l-0.157,-1.174l-0.445,-0.159l-0.839,0.508l-0.656,-1.077l0.577,-0.761l0.838,0.665l0.445,-0.794l0.184,0.445l-0.472,0.634l0.813,-0.127l0.104,0.443h0.393l-0.235,-1.997l-4.035,-1.969l-0.472,0.032l-0.262,0.604l0.472,0.158l0.472,1.491l1.126,0.159l-0.419,1.776l0.236,0.762l1.441,0.697l-1.782,0.317l-0.524,0.73l0.027,0.729l-1.755,1.459l-0.524,0.032l-0.576,1.426l0.655,0.951l-1.336,1.521l0.89,0.952l1.651,0.221l-0.025,0.762l1.179,1.394L224.525,633.731zM218.474,618.858l-1.31,-1.111l-0.787,-0.158l0.341,-0.667l-0.97,-0.95l-0.786,-0.129l0.052,-0.729l-0.603,0.159l0.183,1.015l-0.786,0.382l-1.047,2.729l-0.419,-0.063l0.708,1.441l-1.546,-0.553v-0.825l-0.34,0.223l-0.079,1.08l-0.262,-0.256l-0.472,0.256l0.052,0.506l1.258,0.763l-0.42,1.015l0.708,0.476l0.681,-0.127l-0.708,0.539l-0.838,-0.19v0.317l0.708,0.35l0.603,1.87l-0.655,0.508l0.628,0.665l0.314,-0.349l0.367,0.191l-0.209,0.791l-0.996,0.666l1.022,0.032l0.419,1.142l-0.813,0.159l-0.235,-0.762l-0.943,0.316l0.184,-0.349l-1.153,-1.269l-2.411,-0.981l-1.206,0.38l0.708,2.188l-0.262,-0.033l-1.441,-2.727l-0.577,-0.57l-0.551,0.063l-0.209,-0.855l0.341,-0.54l0.629,-0.03l0.208,-0.604l-1.1,-0.349l0.053,-1.587l0.629,-0.063l-0.289,-0.285l0.524,-0.413l1.336,0.19l0.158,-0.317l-0.498,-0.285l-0.785,0.222v-0.825l-1.022,0.953l0.366,-1.524l-0.759,0.382l-0.053,-0.286l0.236,-0.73l1.232,-0.539l-0.236,-0.92l0.629,0.475l1.047,-0.569l-0.079,-0.699l0.551,-0.032l-0.131,-0.697l1.913,0.063l-1.101,-0.698l-0.708,0.097l0.629,-0.826l-0.681,-1.334l-0.341,0.89l-0.654,0.189l-0.026,-1.587l-1.285,-0.381l1.206,-0.255l0.157,-0.477l-0.393,0.033l-0.209,-0.921l-0.761,-0.541l-0.131,-1.302l-1.1,-0.35l-0.21,0.54l-0.601,-0.032l-1.207,-0.382l0.184,-1.619l1.153,-0.985l0.445,-1.176l-0.97,0.127l-0.681,-0.382l-0.786,-4.005l-1.231,0.604l-1.31,0.097l0.184,3.051l-0.604,0.763l-1.78,-0.539l-0.525,0.477l-0.995,0.095l-0.158,0.478l-0.655,-0.128l-0.052,-1.398l-0.419,0.031l-0.42,1.367l-3.353,1.334l-1.284,-1.334l-2.332,-0.096l-0.052,0.349l0.76,0.414l1.52,0.414l0.917,1.46l0.524,-0.285l1.65,0.509l0.917,-0.413l0.262,0.222l-1.493,1.303l-1.598,0.699l-0.708,1.08l-0.079,0.92l-1.939,-0.095l0.314,0.317l2.227,0.128l0.891,0.793l-0.393,1.238l-1.651,0.794l-0.733,1.078l1.545,3.396l0.787,0.636l0.393,-0.159l0.523,0.382v0.539l1.573,0.888l0.209,0.952l0.602,0.381l-0.445,0.697l0.838,-0.443l0.996,0.475l-0.235,1.364l1.205,-0.824l-0.053,0.824l0.944,0.095l-0.471,-1.078l1.467,-0.126l-0.026,0.855l-0.419,0.064l0.052,1.078l1.545,0.507l-0.026,0.889l-1.179,-0.666l-0.341,0.823l-0.55,-0.127l-0.367,-0.824l-0.471,0.444l0.838,0.919l2.777,0.603l-0.262,0.698l0.419,0.665l-0.183,0.507l0.864,1.142l-0.026,1.235l-1.704,1.425l-0.052,0.982l-0.55,-0.538l-0.472,-0.126l-0.366,0.569l-1.049,-0.697v-1.204l-0.394,-0.063l-0.052,0.887l-1.179,0.792l-0.996,-0.57V634.3l-1.466,0.634l-0.367,-0.222l0.131,-0.475l-0.682,-0.223l-1.415,0.54l-2.542,0.031l0.052,0.665l2.358,-0.189l0.236,0.95l1.31,-0.793l-0.393,1.363l-0.628,0.569l-1.572,-0.189l-0.183,1.077l1.965,-0.57l1.073,0.444l1.18,-0.065l-0.629,0.569l1.363,-0.314l0.629,0.569l-0.603,0.761l0.419,0.948l-0.63,-0.284l-0.235,0.761l-0.393,-0.033l0.733,1.204l-0.289,0.285l0.184,0.696l-1.257,-0.823l-0.813,-0.064l-0.471,0.634l0.367,0.127l-0.236,0.918h-1.049l-0.367,-0.602l-1.048,0.728l1.126,1.424l-0.236,0.918l-0.288,-0.379l-0.472,0.349l-0.131,-0.444l-0.445,0.855l-0.394,-0.064l-0.209,-0.728l-1.127,-0.57l-0.471,1.614l-0.314,-0.063l0.184,-0.631l-0.499,0.031l-1.074,0.917l-0.577,-0.095l1.127,1.012l-0.367,0.443l-0.838,-0.728l-0.472,0.474l1.232,0.761v0.378l0.445,-0.189l0.261,1.013l-1.125,0.822l-0.996,-0.063l-0.681,-0.917l-0.524,0.127l0.026,-0.633l1.1,0.03l-0.708,-0.979l-0.393,0.441l-0.105,-0.664l-0.682,0.189l0.341,-0.854l-0.812,-0.03l-0.577,-0.76l-1.65,-0.443l0.444,-1.297l0.97,-0.633l-2.751,-2.627l-0.969,0.031l-0.026,0.728l-1.179,-0.379l0.209,-0.792l-1.153,-0.982l-0.656,-0.063l-0.576,-1.044l0.08,2.596l-0.892,-0.475l-0.393,-0.855l-1.127,0.063l-0.105,-0.443l-0.786,0.917l-0.053,0.823l-0.498,-0.664l-2.934,0.35l-1.467,-0.793l0.078,-1.234l-0.943,-0.634l0.471,-1.932l1.126,-1.108l0.577,0.032l-0.183,-0.634l1.101,-0.697l-0.237,-0.664l0.577,-1.205l0.209,0.792l0.734,0.284l1.232,-0.379l-0.367,-0.92l0.419,-0.253v-2.409l2.542,-2.535l2.673,-0.667l0.419,-2.473l1.101,-1.078l-0.708,-0.855l0.314,-0.795l1.153,-0.539l1.074,-1.428l0.681,0.538l0.42,-0.854l0.549,0.063l-0.078,2.251l0.499,0.032l0.078,0.477l-0.733,2.409l0.759,0.794l2.673,0.254l0.654,-1.142l-0.366,-0.824l0.942,-1.047l0.472,-1.903l1.126,-0.35l-0.104,-0.508l-1.048,-0.031l-0.629,-4.158l-1.257,-0.127l-0.786,0.38l-1.127,2.19l-0.446,-0.603l-1.52,-0.635l-0.76,1.143l-0.786,-0.761l-0.942,-2.541l-1.546,0.35l-1.729,2.158l-0.341,2.254l-0.786,1.364l-0.707,0.286l-0.681,1.174l-3.852,0.128l-0.681,-0.983l-0.628,-0.224l-1.363,1.237l-0.445,1.491l-1.127,0.919l-2.935,1.079l-0.419,0.475l0.157,0.699l-0.628,0.284l-0.891,1.49l-0.864,-0.064l-1.887,1.332l-3.327,-0.38l-1.992,0.316l0.839,0.539l0.654,-0.443l1.547,0.158l-0.027,0.952l1.39,0.759l-0.027,0.349l-0.996,0.096l0.131,0.761l-0.577,0.443l-0.209,1.362l-1.074,0.95l0.943,0.696l1.625,-0.316l-0.131,1.488l-0.262,0.286l-0.498,-0.888l-0.838,0.127l0.026,2.471l-1.546,-0.381l-1.153,1.299l0.236,0.729l1.415,1.298l-0.026,0.506h-0.918l-0.366,1.552l1.179,0.822l0.314,1.266l-0.733,0.285l-0.367,-0.317l-0.943,0.854l-1.389,-1.582l-0.576,0.823l0.367,1.581l0.604,0.729l-0.84,1.044l-1.047,-0.032l-0.603,-0.759l-4.717,-0.189l1.521,2.467l-0.158,1.453l-1.205,-1.802l-1.546,-0.506l-1.048,-1.075l-0.629,-0.189l-0.812,0.601l-1.101,-0.063l-1.284,-0.918l0.289,-1.392l-2.043,-0.063l0.078,-0.854l0.943,-0.379l-0.734,-3.134l0.263,-0.379l-0.472,-0.317l0.472,-1.584l-0.105,-1.582l0.683,-0.76h-0.525l-0.131,-0.507l-0.157,-0.887l0.576,-0.824l-0.864,-1.013l0.235,-1.172l-1.021,-0.919l0.367,-0.381l-0.367,-2.408l0.498,-1.584l0.655,-0.604l-0.314,-0.189l-0.681,1.966l-0.865,0.761l-0.603,9.406l0.55,0.635l-0.969,0.253l-0.079,0.412l0.262,2.215l0.419,0.412l-0.656,0.315l0.105,0.54l-0.682,-0.097l-1.31,0.791l0.786,1.551l-2.201,3.29l-0.55,-0.38l-0.839,0.791l-0.969,-0.127l-1.704,1.613l-0.628,-0.191l0.366,0.799l-0.445,0.151l-0.812,-0.822l-0.603,0.695l-0.76,-0.22l-0.524,1.485l-0.969,-0.254l-0.55,1.043l-0.55,-0.569l-0.602,0.791l0.496,0.568l-0.942,1.169l0.287,0.76l0.551,-0.031l-0.053,2.339l-1.703,1.072l0.603,0.507l-0.787,1.011l0.289,0.758l-0.209,1.104l0.445,0.505l-0.813,0.317l-0.996,-0.885l-2.462,-0.284l-1.494,2.21l-1.441,0.253l-0.341,1.01l-0.865,-0.315l0.262,-2.209l-0.655,-0.538l1.388,-1.674l-0.603,-1.138v-1.926l-1.44,-0.633l-0.551,0.728h-0.838l-1.126,1.137l-0.655,0.158l-0.001,-0.632l-0.602,-0.443l-0.079,-0.537l0.393,-0.125l0.917,0.853l0.21,-0.348l-0.42,-0.663l0.97,0.094l-0.838,-0.663l0.368,-0.694l-0.735,-0.127l-0.052,-0.728l2.384,-0.411l-1.127,-1.58l0.289,-0.474l-0.236,-0.38l1.52,0.475l0.157,0.442l1.074,-1.645l-0.734,-1.264l0.498,-0.854l-0.471,-0.696l-1.126,0.917l-0.472,-0.378l-0.813,0.094v0.98l-0.707,-0.222l-0.656,-1.297l-1.258,-0.917l-0.104,-0.38l0.943,-0.474l0.602,0.759l0.524,-0.285l-0.76,-0.727l-0.052,-0.603l0.629,-0.347l-0.418,-0.697l-0.629,0.254l-0.735,-0.949l0.027,-0.569l0.969,-0.157l-0.917,-2.058l1.336,-0.823l-0.786,-1.361l-1.913,-0.157l0.131,-0.569l1.021,-0.191l1.049,-0.919l-0.315,-0.823l-0.97,0.191l-0.078,0.505l-0.995,-0.063l-0.027,-1.583l-2.279,-0.792l0.209,1.204l-1.494,0.252l0.026,0.952l-1.441,0.695l-0.786,-0.792l0.917,-1.107v-1.235l-2.202,-0.095l-2.855,-1.426l-1.992,0.696l-0.943,-1.14l0.865,-1.014l-3.171,-1.173l0.524,-0.982l-0.446,-0.602l0.314,-1.015l-0.288,-0.349l1.231,-1.014l-0.419,-0.57l-0.446,0.633l-1.179,-0.285l-1.179,-1.142l-0.393,-2.789l0.393,-0.635l-0.445,-0.761l0.76,-0.697l-0.446,-1.079l0.289,-1.364l0.576,0.443l0.682,-1.109v-1.747L85,614.955l1.311,-0.54l1.048,0.984l-0.315,0.729l1.258,-0.126l-0.289,0.761l0.917,0.509l0.367,1.968l0.838,0.254l0.918,1.142l0.025,0.635l-1.572,0.667l-0.236,1.935l0.394,0.824l-0.708,0.984l0.209,0.571l2.332,0.855l-0.104,2.884l1.309,0.634l0.262,1.839l0.42,-1.301l0.602,-0.188l2.018,1.363l0.708,-0.191l-0.131,0.666l4.14,2.218l-0.183,-0.887l2.882,-1.457l0.445,-1.142l-0.079,-0.539H103l-0.654,0.634l-0.55,-0.285l-0.812,0.634l-0.446,-2.885h-0.524l-0.655,1.174l-0.812,-2.441l-1.049,0.253l0.499,-1.837l-0.734,-0.064l0.052,-0.824l-0.864,0.031l-0.314,1.235l-0.602,-0.188l-0.787,1.107l-1.075,-0.949l1.646,-1.968l-0.178,-1.871l-0.524,-0.538l0.603,0.094l0.524,0.825l0.472,-0.412l-0.184,-0.761l-0.576,-0.223l0.026,-0.793l-1.048,-0.19l0.052,-0.54l0.655,0.317l0.341,-0.729l1.546,2.126l-0.105,0.888l0.367,0.477l0.943,-1.078l0.577,-0.063l0.131,-0.761L99.438,622l0.55,-0.952l1.127,0.667l-0.158,0.634l-1.31,0.889l-1.1,2.062l1.126,1.269l0.97,-0.381l-0.026,0.889l0.891,0.125l0.733,1.079l3.931,0.506l1.572,1.364l0.997,-1.332l-1.311,-0.381l-0.236,-1.236l0.367,-0.158l2.201,0.223l0.313,0.889l3.25,1.395l3.092,0.284l0.444,-0.443l-0.89,-0.761l-1.913,-0.096l-1.415,-1.395l-1.598,-0.825l-0.367,-1.362l0.602,-1.301l-1.257,-0.381l-1.127,0.253l-1.179,-2.918l-2.672,-3.173l-0.944,-0.382l-1.52,0.127l-0.733,0.191l-0.707,0.92l-0.499,-0.253l-0.236,-1.396l-1.257,0.031l-0.445,0.507l-0.236,-0.666l-0.891,0.253l-0.446,-0.665l-0.655,0.38l-0.053,0.604l-1.1,-0.128l0.184,0.636l-0.786,0.349l-2.333,-0.856l-0.052,-0.477l1.677,-1.079l-0.262,-0.761l0.55,-0.477l-0.498,-0.319l1.153,-0.442l-0.079,-1.335l-1.991,0.128l-0.708,-2.167l0.865,-1.042v-0.794l0.471,-0.667l0.603,0.19l0.184,-0.921l0.341,-0.445l0.393,0.127l0.131,-0.698l0.786,-0.604l1.021,-0.096l-0.707,-0.54l-0.131,-1.971l-0.76,-0.381l0.628,-1.304l-0.733,-0.254l-0.55,-0.097l0.445,-1.239l-0.157,-0.731l0.419,0.254l0.419,-0.254l0.445,-1.272l-1.283,-1.209l-0.184,-0.668l0.655,-0.731l-0.786,-1.21l0.524,-2.228l-1.153,-0.764l-0.105,-1.91l-0.812,-1.336l-0.446,0.571l0.131,2.197l-0.864,0.7l0.079,0.764l0.786,-0.127l0.629,0.732l-0.892,1.432l0.76,0.509l-0.708,0.859l0.394,0.923l-0.236,0.413l-1.52,-0.127l-0.105,0.542l-0.629,0.222l-1.362,-0.159l-0.236,-1.622l-0.943,-0.223l-0.498,0.699l-0.472,-0.222l-0.183,-0.732l0.445,0.19l1.048,-1.241l-1.074,-0.477l-0.236,-0.892l-1.126,-1.146l0.208,-1.178l0.499,-0.096l0.208,-0.892l0.708,-0.382l-0.288,1.401l0.681,0.032l0.262,-0.701l0.812,1.688l1.887,-0.957l0.34,-0.892l0.629,-0.157l-0.027,-0.988l-1.86,-0.414l4.9,-3.152l-0.079,-1.497l-0.891,-1.116l-0.969,0.034l-1.651,0.795l-0.419,-1.02l0.419,-0.444l-0.262,-0.574l-1.651,-0.415l0.813,-0.255l0.445,-0.701l-1.153,-2.168l-1.336,-0.03l-0.132,0.732l-1.363,-0.956l1.206,2.23l-1.363,1.051l1.048,0.288l0.21,0.604l-1.284,1.211l-0.707,-1.719l-0.76,-0.352l-0.787,0.893l-1.284,0.096l0.079,-1.052l-0.682,-1.944l-1.021,-0.669l0.419,-1.276l1.651,-0.128l-2.202,-2.424l0.813,-1.912l0.393,0.479l0.367,-0.169l-0.472,-0.756l0.209,-0.541l1.468,-0.894l0.708,1.913l0.996,-0.223l-0.314,-0.512l0.367,-0.095l1.362,0.414l0.079,1.245l1.284,-0.064l0.917,-1.627l-0.682,-0.446l0.079,-0.32l0.368,-0.383l0.602,0.383l1.075,-1.276l0.052,2.554l-0.786,1.625l0.288,0.191l-0.184,0.512l-0.76,0.223l-0.183,0.893l0.524,0.383l0.053,0.828l-0.524,0.353l1.205,0.224l0.891,-1.021l-0.079,1.625l-0.681,0.446l0.052,0.574l0.367,0.255l0.235,-0.446l0.629,0.605l0.734,-0.573l0.209,1.942l0.419,-0.095l0.76,-2.104l1.048,-0.542l-0.655,2.264l0.472,0.159l0.655,-1.339l0.997,1.529l0.026,0.415l-1.572,1.848l0.97,-0.032l0.104,1.849l2.228,-0.064l-0.603,-0.987l0.025,-0.765l0.42,-0.605l1.677,-0.796l1.441,-2.296l-2.069,-0.954l2.096,-0.67l0.655,-1.18l-1.704,-0.638l-2.358,-0.096l-1.624,-3.158l-1.205,-0.51l-0.812,-1.403l0.026,-0.733l-0.917,-0.129l-0.604,-1.054l-0.654,-0.062l0.289,-1.341l-0.996,-0.479l1.624,-0.543l-0.183,-1.116l0.577,-0.287l0.288,-1.149l-1.782,0.895l-0.026,-0.416l-0.996,-0.224l-1.284,0.607l-0.393,-0.607l-1.179,-0.191l0.184,-0.766l-0.445,-0.958l-0.576,-0.543l-0.787,-0.064v-0.511l1.101,-2.076l0.656,1.533l0.654,0.543l0.026,0.767l0.629,-1.15l0.734,-0.223l-0.551,-0.99l1.599,-2.172l-0.288,-0.704l-1.284,0.448l-0.472,-0.416l0.734,-1.31l3.118,0.032l0.629,-2.365l0.104,-2.91l1.755,-4.444l1.467,0.575l0.682,-0.19l0.942,0.99l1.599,0.191l-0.235,-0.671l-1.048,0.191l-0.315,-0.735l-1.86,-1.151l-0.759,-2.399l0.733,-1.793l-0.289,-0.544l1.468,-1.409l2.227,0.162l0.315,-0.578l1.939,0.182l0,0l1.869,0.622l0,0l1.868,1.557l0.779,2.652l0.155,2.953l1.869,2.181l1.246,4.046h1.708l0.375,1.698l0,0l4.341,-0.232l1.448,-1.54l0.983,-0.353l1.11,0.24l0,0l0.963,0.428l2.07,-0.709l0,0l1.527,-1.492l3.134,-0.962l0,0l2.408,-1.217l0.764,-2.01l-0.141,-0.955l0,0l-0.261,-0.771l0,0l0.152,-0.682l1.448,-0.944l0,0l0.585,-0.674l-0.149,-3.091l0,0l0.183,-1.178l0.609,-0.808l2.262,-0.979l0,0l1.524,0.354l0,0l1.083,0.215l1.564,-1.861l3.018,0.604l2.939,1.855l1.095,1.129l2.517,4.761l0,0l1.033,0.895l0,0l1.968,0.567l1.021,-0.693l0,0l0.138,-1.019l0,0l0.532,-2.077l0.997,-0.641l0.979,-1.783l0.704,-0.317l1.806,0.394l1.347,1.039l0.613,1.9l-0.157,2.503l0,0l-1.146,1.374l0.087,0.934l0.488,0.682l1.587,-0.015l0,0l1.009,2.871l-0.419,3.604l2.586,1.972l0,0l2.093,0.538l0,0l1.607,-0.146l1.42,-0.939l0,0l0.962,-0.897l0,0l1.298,-0.834l3.148,1.353l0,0l1.927,-1.12l1.437,1.37l0,0l1.125,0.654l6.141,-0.02l0,0l2.377,-0.696l3.187,0.363l0,0l1.125,-0.021l0.622,-0.441l2.945,-3.787l1.751,-0.981l0,0l1.992,-0.108l0,0l3.5,1.155l1.033,0.918l0,0l3.297,1.813l3.066,2.64l0,0l-0.783,0.695l-0.016,1.56l2.654,2.981l0.905,9.198l1.296,1.686l2.219,1.127l3.036,3.633l0.193,2.896l0,0l1.09,1.043l0,0l0.766,1.236l1.613,0.686l1.176,1.869l0,0l1.741,1.326l0,0l1.573,4.103l-0.037,2.928l0.695,0.322l0.001,0.864l-1.834,0.286l-0.944,-0.379l-1.362,-2.962l-0.576,-0.031l-0.63,1.145l-1.755,0.542l-0.053,-2.897l-1.415,-2.037l0.079,1.624l0.681,0.542l0.367,3.023l-1.546,1.177l-0.236,0.923l-0.629,-0.191l-0.682,0.892l-0.707,0.063l-0.183,0.478l0.472,0.955l-1.625,1.112l-1.572,0.413l0.21,0.477l-1.153,0.892l-0.944,-1.21l0.446,-0.571l-2.07,0.222l-0.472,-1.304l-1.048,-0.954l0.158,-2.45l-0.708,-0.668l0.288,1.21l-0.419,1.781l-1.152,0.19l-0.315,-0.287l-0.499,0.637l1.154,0.287l1.284,1.59l-0.498,0.795l0.604,1.019l-0.499,0.19l-0.498,-1.019l-0.733,0.701l-0.603,-0.541l-0.577,0.636l1.101,0.128l0.34,0.413l0.079,1.367l1.39,1.366l-0.262,0.414l0.366,0.604l0.367,0.222l0.42,-0.413l0.681,1.019l1.415,-0.159l-0.078,0.763h-0.813l-0.052,0.54l0.235,0.699l0.917,0.73l0.026,-1.112h0.838l1.467,0.794l1.206,-1.303l1.336,-0.476l0.917,-1.526l-0.551,-0.445l0.052,-0.762l0.604,0.921l0.104,-0.381l1.494,0.095l1.572,-0.668l-0.943,0.859l1.756,0.699l-0.13,-0.764l2.305,-0.826l1.336,1.336l-0.838,0.19l0.313,0.856l-0.708,2.318l0.656,0.193l-0.682,0.349l0.131,2.161l-0.891,-0.064l-0.288,1.525l-1.049,1.081l0.76,1.396l-0.34,1.175l0.524,0.382l-0.577,0.412l0.786,0.571l-0.184,0.603l-0.419,0.286l-1.572,-0.286l-0.262,1.111l-2.516,0.952l-0.654,-0.031L218.474,618.858zM154.367,566.929l-2.607,-0.262l-1.018,-4.53l-1.937,-2.335l-1.826,-0.868l-2.433,-0.086l-2.433,0.954l-2,1.044l-1.998,2.085l-1.478,0.087l-2.086,-0.696l-1.478,-1.39l-0.608,-2.172l-2.173,-0.087l-2.085,5.302l-2.346,-0.087l-1.738,2.085l-1.13,4.78l0.435,4.084l7.213,1.042l1.825,2.26l1.912,3.824h3.737l3.389,-1.999h3.823l1.478,-1.042l3.128,0.607l3.389,-2.347l1.39,-1.824l0.782,-1.651l0.087,-2.607l0.869,-1.825v-1.391L154.367,566.929zM203.118,650.224l-1.598,-0.602l0.079,-0.411l-1.494,-1.866l-0.052,1.14l-0.419,0.189l-0.263,-0.602l-0.445,1.012l-0.917,-0.031l0.655,-0.822l-1.676,0.158l-0.524,-0.791l-0.918,-0.568l-0.314,0.189v1.929l0.393,0.633l-0.812,0.476l0.157,0.284l1.074,-0.76l0.524,0.253l0.445,-0.285l0.996,0.603l-0.21,0.632l-1.466,-0.602l-0.394,0.381l1.205,1.265l0.891,-0.506l0.209,0.506h0.576l0.21,0.822l-0.76,0.917l0.053,0.475l0.445,0.221l2.384,-1.202l0.314,-0.505l0.995,0.474l0.76,-0.948l-0.235,-0.695L203.118,650.224zM227.749,644.688l-0.55,0.03l0.026,-0.663l-2.463,-0.855l1.389,-0.063v-0.444l-0.13,-0.634l-1.704,-1.614l0.184,-0.569l-0.734,-1.583l-1.704,0.031l-2.541,1.741l-0.682,-0.316l-0.734,0.191l0.393,0.728l1.101,0.348l0.681,0.697l1.258,-0.412l-0.734,1.171l0.184,0.38l1.311,0.317l-0.734,0.538l0.131,0.349l0.655,0.221l1.179,-0.411l-0.026,0.633l1.65,0.284l-0.209,0.475l-0.656,0.096l0.812,0.381l1.887,0.125l0.131,-0.506L227.749,644.688zM222.534,599.513l-1.494,0.095l-0.943,-0.828l-1.755,0.67l-0.682,1.177l0.944,0.73l-0.472,0.445l1.782,0.095l0.471,0.477l0.917,-1.906l1.573,-0.383L222.534,599.513zM128.836,658.128l0.604,-0.443l2.148,0.127l-0.708,0.79l-0.602,1.802l1.388,0.821l-0.315,-0.506l0.472,-0.633l-0.131,-0.757l1.075,-1.453l1.021,-0.443l1.519,0.347l0.42,-0.536l-0.367,-0.442l0.498,-0.98l1.808,0.507l0.498,0.727l0.445,-0.412l1.101,0.316l0.079,-0.821h-0.708l0.236,-0.411l-0.393,-0.948l-0.812,0.127l0.472,-0.602l-0.262,-0.632l-1.1,0.822l-1.415,-1.013l1.782,-0.095l0.288,-0.979l-0.577,-0.57l-0.55,0.284l-0.08,-1.392l-3.038,1.392l-1.206,-0.158l-2.227,2.561l0.341,1.361l-0.786,0.378l-0.891,1.296L128.836,658.128zM195.939,646.807l-0.105,-0.568l0.813,-0.348l1.441,0.316l0.393,-0.697l0.131,0.697h0.446l1.126,-0.823l-1.388,-1.962l-2.883,-0.223l-0.236,-0.57l0.393,-0.221l1.206,0.38l-0.498,-1.141l-1.074,-0.189l0.053,-0.443l1.388,-0.094l0.445,-0.697l-0.47,-0.918l-1.521,-0.159l-0.445,0.286l-1.782,2.596l0.551,0.538l0.838,-0.158l0.655,0.665l-0.419,0.537l0.655,0.063v0.382l-1.677,1.043l0.812,0.76l0.131,0.792L195.939,646.807zM228.691,650.16l-0.603,-0.412l0.314,-1.011l-1.074,0.569l0.289,0.886l-1.153,2.215l1.493,-0.255l0.026,0.316l-1.125,0.253l-0.367,1.075l0.262,0.538l0.865,-0.475l0.104,0.821l0.707,0.032l-0.288,-0.632l0.498,-0.158l-0.184,-1.328l0.943,-2.909L228.691,650.16zM152.287,662.677l-0.576,0.349l-0.786,-0.57l-1.415,0.222l-1.153,1.359l0.262,2.115l0.55,-0.379l0.262,0.947l0.55,0.315l0.393,-0.6l2.333,-0.885l0.209,-0.885l1.075,-0.22l-0.13,-0.916l-0.604,0.063L152.287,662.677zM138.74,666.056l1.101,-0.505l-0.393,-0.789l0.341,-0.157l0.786,0.946l-0.262,0.505l1.074,-0.029l0.314,-1.58l-0.551,-0.315v-0.443l0.656,-0.348l0.838,0.19l0.104,-1.516l-1.677,0.915l-0.708,-1.452l-1.441,0.41l-0.131,-0.663l-0.681,0.852l-0.55,-0.504l0.078,-0.411l-1.021,-0.694l-1.363,1.294l0.131,1.042l-1.231,0.506l-0.445,0.031l-1.153,-1.452l-1.388,1.263l-1.179,-0.41l-0.995,0.285l0.445,0.473l2.279,0.505l1.205,1.391l1.441,-1.391l1.861,0.128l0.497,0.441l0.131,0.885l0.42,0.094l-0.314,0.822l0.472,0.883l0.838,-0.252L138.74,666.056zM160.173,661.13l0.314,-0.569h-0.916l0.025,-0.475l-0.995,0.128l-0.603,0.852l-1.31,0.285l-0.235,-0.758l0.366,-0.159l-0.393,-0.506l0.314,-0.536l-0.55,-0.063l-0.996,-1.391l-0.21,0.884l-1.153,-0.505l-0.471,0.505l0.629,0.633l-0.183,0.315l-0.368,-0.474l-0.34,0.221l0.419,0.348l-0.419,0.79l-2.122,-0.315l2.122,1.232l0.708,-0.729l1.336,0.854l0.34,0.79l-1.415,0.314l0.812,0.158l0.341,0.506l0.445,0.031l0.367,-0.947l1.231,-0.032l0.13,0.727l-1.572,1.105l0.419,1.831l0.943,-1.862l0.498,0.158l0.21,-1.073l2.017,-0.506l-1.702,-0.284l0.55,-0.884l0.576,0.44l1.311,0.128l0.183,0.6l0.759,0.252l0.473,-0.283l-0.656,-0.632L160.173,661.13zM146.024,656.801l-0.969,-0.474l-0.838,0.41l-0.603,-1.327l-0.655,0.6l-0.472,-0.695l0.131,0.822l-0.288,0.095l-0.996,-1.266l-0.053,0.538l-0.708,0.253l-0.366,-0.316l0.314,-0.568l-0.866,-0.411l-0.314,0.632l0.759,0.633l0.183,0.727l-0.785,2.37l0.68,0.569l1.336,-0.6l0.315,1.611l0.969,0.094l0.813,0.601l0.209,-0.664l0.786,0.38l0.629,-0.505l0.393,-1.169l0.891,0.504l0.918,-0.157l0.209,-0.79l-0.865,-1.169l0.289,-1.2l0.733,-0.917l-0.549,-1.107L146.024,656.801zM176.76,672.652l-1.441,0.316l-0.026,1.167l-0.917,0.095l-0.707,2.776l0.367,-0.283l0.917,0.03l0.184,-0.408l0.366,0.472l1.31,0.38l-0.052,-0.884l-0.76,-0.316l1.1,-0.283l-0.288,-1.104L176.76,672.652zM174.559,647.091l-0.289,-1.106l-1.546,-1.109l-1.389,0.857l-0.393,-0.033l-0.052,-0.475l-1.572,0.222l-1.573,1.266l-1.362,-0.126l-0.549,0.886l-0.576,-0.032l0.025,-0.695l-0.786,0.094l-0.419,-1.424l-0.472,0.443l-0.314,-0.379l-0.157,1.612l-0.681,0.128l-0.42,0.728l-0.549,-0.602l-0.342,0.411l1.258,1.739l-0.655,0.508l0.263,0.442l-0.263,0.442l0.865,0.095l0.027,-0.602l0.733,-0.125l-0.079,1.075l0.813,0.221l0.052,0.696l1.127,0.221l0.523,0.98l0.053,-0.822l0.524,-0.411l1.468,0.285l-0.157,-0.538l0.365,-0.221l1.992,0.568l2.043,0.063l0.838,-0.821l0.445,-2.118L174.559,647.091zM156.61,648.863l-0.97,0.537l-1.1,0.033l0.21,0.506l0.89,0.158l0.341,3.193l0.812,0.791l0.603,-0.316l-0.262,-1.265l0.472,-0.222l0.576,0.475l-0.236,0.822l0.367,1.96l1.021,-1.676l-0.629,-0.506l0.813,-0.253l-0.026,-0.694l-0.917,-2.531l-0.969,-0.823l0.184,0.442l-0.577,0.317L156.61,648.863z"/>
			        <path id="KR-47" title="37000" class="land" d="M611.344,326.247l0.052,0.262l0.185,0.131l-0.185,0.034l-0.026,0.131l-0.313,-0.065l-0.079,-0.361l0.156,-0.099l0.105,0.099L611.344,326.247L611.344,326.247zM611.815,326.508l0.185,0.295l-0.341,0.228l-0.159,-0.196L611.815,326.508L611.815,326.508zM611.213,325.82l0.079,0.163l-0.158,0.165l-0.025,-0.262L611.213,325.82L611.213,325.82zM521.21,290.971l0.94,0.28l-0.734,0.38l-0.318,1.082l0.957,1.76l-0.733,2.6l0.94,0.68l-0.988,0.36l-0.845,0.96l-0.462,-0.181l-1.228,0.72l-0.749,1.899l-0.573,-0.56l-1.785,-0.58l-0.876,0.18l-1.467,-1.135l-1.594,-0.36l-0.653,-1.06l0.239,-2.44l-1.035,-1.199l0.031,-1.081l0.749,0.48l4.048,-2.081l1.402,0.08l1.435,-0.94l1.626,0.24l0.765,-0.861l0.732,0.04L521.21,290.971zM298.396,513.212L298.396,513.212l0.691,1.275l-0.467,3.045l0,0l0.787,2.368l0.895,1.291l2.114,1.687l0,0l0.939,1.081l1.382,0.7l0,0l5.868,-1.104l0,0l3.434,0.771l3.992,1.97l0,0l1.918,0.572l1.563,-0.56l3.938,-3.266l1.011,0.298l0,0l1.135,-0.438l1.802,-2.29l0,0l2.017,-1.413l0,0l2.101,0.042l0,0l1.334,0.103l1.59,0.768l0,0l1.282,0.704l0,0l2.414,0.864l0,0l0.958,-0.353l0,0l0.769,-0.789l3.913,-3.082l1.656,-0.175l0,0l0.671,0.13l0.656,-0.863l-1.351,-2.474l-0.223,-1.061l0.594,-0.493l4.146,-2.573l3.106,-1.02l1.623,0.299l2.585,-0.653l1.091,0.422l1.798,1.466l2.008,0.31l0.969,0.585l0.237,0.826l0,0l-0.424,2.836l0,0l0.287,0.771l0.729,0.334l0,0l1.972,0.649l0,0l1.424,-0.241l2.817,-1.839l1.113,-0.307l0,0l1.484,-0.011l0,0l4.878,1.729l0,0l1.758,0.423l0,0l3.007,0.221l-0.812,-0.257v-0.546l-0.63,-0.576l-0.236,-2.312l0.761,-0.385l0.498,-1.991l1.049,-0.097v-1.604l0.523,0.063l0.628,-1.348l-0.446,-1.831l1.233,-2.797l-0.132,-1.478l0.97,-0.996l-0.342,-0.804l0.264,-1.255l0.367,-0.191l-0.631,-1.897l0.971,-0.771l-0.264,-0.58l0.892,-0.899l0.341,0.192l0.236,-1.351l-0.524,-0.772l1.128,-1.513l-0.184,-1.352l0.681,-0.547l0.053,-1.093l0.785,-0.999l-1.598,-0.322l0.209,-0.805l0.891,-0.259l-0.444,-1.318l0.864,-0.741l-1.467,-2.351l-0.053,-0.87l1.44,-0.774l0.682,-1.675l0.811,-0.193l-0.183,-0.516l0.786,-1.45l-0.366,-1.193l1.389,-1.225l-0.026,-0.87l1.703,-2.258l-0.681,-0.936l0.498,-0.419l0.052,-0.42l-0.55,-0.354l0.394,-0.161l0.235,-1.128l-1.311,-2.583l0.104,-1.162l-0.969,-0.291l-0.211,-0.774l-1.229,0.291l-0.027,0.936l-0.892,1.355l-3.064,3.323l-0.053,1.323l-4.165,2.483l-0.235,1.226l-0.815,0.257l-2.539,-0.999l-0.421,-0.773l0.709,-0.839l-0.55,-0.516l-2.333,0.613l0.184,-0.743l0.734,-0.354l0.443,-0.808l1.39,0.323l0.892,-0.098l-0.025,-0.419l-2.595,-0.936l-1.679,1.162l-0.994,-1.646l0.654,-2.323h1.311l0.497,-0.774l1.652,-0.582l-0.184,-1.45l1.206,-1.066l0.103,-0.581l0.079,-0.969l-3.011,-2.487l-0.474,-1.131l0.628,-1.68l-0.024,-1.229l-0.604,-1.971l-0.184,-0.388l-1.206,-0.227l-0.838,-1.584l0.21,-0.711l0.838,-0.227l0.34,-1.293l-0.444,-1.294l0.444,-1.003l-1.23,-1.455l0.289,-1.941l0.523,-0.55l-0.682,-1.586l0.446,-0.259l0.287,-3.659l-0.261,-1.229l0.891,-1.846l-0.08,-0.972l1.679,-2.884l0.209,-1.037h0.471l1.65,-2.398l0.577,-1.913l-0.289,-1.686l0.421,-2.757l-0.369,-1.85l1.076,-0.974l0.105,-1.785l0.603,-0.227l-0.471,-0.778h-0.395l-0.288,-4.611l-2.122,-2.403l-0.577,-1.234l-0.184,-1.787l0.604,-0.293l-0.393,-2.502l0.471,-1.854l1.075,-1.203l0.837,-2.601l1.181,-0.977l1.31,0.065l0.394,-1.757l0.865,-0.652l-0.552,-2.57l0.552,-0.521l-0.028,-0.911l-0.812,-1.531l-0.104,-1.302l1.046,-1.107l-1.438,-2.378l-0.577,-3.226l-0.891,-1.043l-0.104,-1.01l-1.677,-1.858l-0.84,-2.414l0.235,-0.62l-0.628,-1.271l-0.077,-0.75l0.549,-0.554l-0.522,-1.337l0.548,-4.244l-1.178,-3.951l1.048,-1.861l-0.052,-1.405l-0.919,-2.777l0.683,-0.523l-0.393,-1.275l0.208,-1.242l0.63,-0.425l0.552,0.359l0.418,-0.294l-0.604,-1.046l-2.855,-2.093l-0.105,-0.622l-1.676,-1.472l-0.185,-1.177l0.551,-0.834l0,0l-4.268,0.714l0,0l-1.867,2.18l-2.492,0.934l-2.802,2.491l0,0l-1.557,2.18v1.246l0,0l1.557,2.802l-6.521,0.161l0,0l-2.652,-2.267l-2.945,-1.029l-2.606,-0.397l-2.542,2.51l-1.006,-0.192l-3.065,-1.745l-3.342,-0.673l-1.164,-0.027l-2.176,0.742l-0.677,-1.32l-1.719,-0.682l0,0l-0.927,0.594l-1.975,3.703l0,0l-0.935,1.245h-4.048l-3.425,-2.802l-2.803,-1.557l-2.015,0.184l-0.646,2.311l0.104,2.396l-0.361,0.753l-0.749,0.363l-1.455,-0.952l-1.605,-0.418l-1.914,0.255l-3.076,-2.091l-1.167,-0.24l0,0l-1.271,1.28l0,0l-0.928,0.874l-0.466,-0.229l0,0l-0.926,-0.326l0,0l-0.749,0.31l0,0l-1.442,2.136l-0.83,0.471l0,0l-0.616,0.28l0,0l-3.283,3.244l-2.797,0.807l0,0l-0.784,1.24l0,0l-0.464,0.997l-3.074,1.744l-0.089,0.88l-1.482,1.469l-1.579,3.308l0,0l-0.833,1.562l0,0l-0.052,1.331l1.312,0.609l0,0l0.531,0.813l0,0l0.262,2.095l-2.838,3.889l0,0l-1.428,0.297l0,0l-2.105,0.152l0,0l-0.454,0.33l0,0l-0.923,1.028l-2.436,-0.052l0,0l-1.641,0.435l-0.547,-0.254l0,0l-1.034,-2.793l-1.454,-2.121l-3.23,-1.843l-1.18,-1.968l0,0l-1.081,1.273l-0.276,1.017l0,0l-0.309,0.75l-1.128,0.344l-0.241,2.583l0,0l-0.204,0.643l0,0l-0.365,0.565l-5.194,-1.294l-0.497,-0.441l0,0l-0.42,-0.628l0,0l-1.063,-0.376l-0.609,0.625l0,0l-1.382,1.146l0,0l-1.148,1.938l0,0l-1.375,0.189l0,0l-1.635,-1.745l-0.506,0.305l-2.704,6.328l0,0l-0.156,0.347l0,0l3.235,4.442l0.152,0.792l-1.188,0.105l-3.403,-1.013l0,0l-1.178,-0.664l-1.206,0.584l0,0l-2.186,-1.014l0,0l-1.122,-0.613l0,0l-1.166,2.334l-1.702,1.39l-1.6,1.042l-2,0.125l0,0l-0.643,0.253l0,0l-1.68,2.37l0.482,2.219l0,0l-0.446,0.697l0,0l-2.203,1.904l0,0l-0.578,0.729l0,0l-0.942,1.505l-0.812,0.045l0,0l-1.56,0.351l0,0l-0.817,1l-0.17,0.903l0.727,1.096l5.354,1.13l1.215,1.218l-0.143,0.929l0,0l0.386,1.555l0.578,0.41l0,0l1.637,0.679l0.367,0.682l-0.422,1.701l0,0l-0.124,0.56l0,0l-1.888,0.332l0,0l-0.429,1.333l0,0l0.294,3.591l-0.672,2.685l0.593,1.178l0.001,1.293l-1.28,2.012l1.313,3.247l0,0l0.494,0.306l0,0l-0.999,2.558l-2.655,2.304l0,0l-0.069,4.276l0.368,0.783l1.781,0.991l0,0l1.842,-1.07l1.158,-1.502l0.407,0.018l0.462,1.441l2.236,0.795l0.258,0.682l0,0l0.092,0.499l0,0l0.98,0.321l0,0l0.774,0.748l0,0l0.335,0.493l0.837,-0.097l0,0l1.983,-0.836l0,0l2.228,-0.787l2.016,0.695l0,0l0.619,1.067l0,0l-0.355,1.064l0.505,2.099l0,0l0.57,1.305l0.688,0.564l0,0l-0.09,0.794l-1.151,0.552l-2.467,-1.476l-2.402,1.423l-1.18,1.738l0.081,1.186l1.094,1.768l-0.511,1.406l0.101,2.158l-1.752,1.46l0.182,0.918l-0.992,1.679l-0.227,2.033l-1.836,2.593l-0.75,0.33l-0.879,-0.664l-1.24,0.237l-1.081,1.07l0,0l3.477,5.653l1.23,3.302l-0.272,2.761l-1.012,2.241l0,0l0.128,1.933l0.571,0.865l1.136,0.895l1.56,-0.012l0,0l0.706,0.364l0,0l0.308,2.603l0.942,0.563l0,0l2.138,0.328l0,0l1.773,0.215l0.583,1.126l1.149,0.634l0,0l4.434,0.782l0,0l2.547,-0.265l0,0l1.488,0.751l0,0l1.54,0.746l0.491,0.737l0.778,2.869l0,0l0.659,0.494l0,0l2.061,0.987l0.66,1.147l-0.232,0.61l2.516,1.49l0.94,1.787l-0.245,2.204l-1.812,3.966l0,0l-0.267,1.655l0.884,1.632l0,0l3.794,1.488l2.239,-0.304l0,0l1.19,-0.311l0,0l2.951,-1.087l2.192,1.083l2.289,0.271l0,0l2.235,2.177l0,0l1.707,1.244l0,0l-0.732,-3.421l-4.048,-4.982l0.312,-2.802l1.868,0.622l1.557,1.246h2.179l0.623,-2.491l-3.113,-3.425l1.245,-3.114l1.246,-2.802l5.294,-0.934l-0.312,-1.869l-2.802,-2.18l-4.67,-0.312l0.311,-3.113l1.245,-2.803l2.18,-3.113l2.18,-0.623l1.869,-1.246l0.622,5.605h2.492l0.934,-3.113l2.492,-4.983l5.915,-1.244l2.803,-3.114l3.424,-0.935l3.113,0.312l3.737,3.114v4.358l0.623,3.113l1.868,4.048l-0.934,2.181l-3.425,1.245l-1.558,3.425v3.113l-2.491,0.313v1.869l1.246,1.557v4.048l-3.426,1.245l-1.557,1.868l-2.802,-0.313l-0.624,-2.801h-3.113l-2.179,1.245l-1.558,2.491l0.451,1.503l0,0l0.3,-0.217L298.396,513.212z"/>
			        <path id="KR-48" title="38000" class="land" d="M239.305,487.755l1.135,0.895l1.561,-0.012l0,0l0.706,0.364l0,0l0.308,2.603l0.942,0.563l0,0l2.138,0.328l0,0l1.773,0.215l0.583,1.127l1.149,0.633l0,0l4.434,0.782l0,0l2.547,-0.265l0,0l1.488,0.751l0,0l1.539,0.746l0.492,0.738l0.778,2.868l0,0l0.659,0.494l0,0l2.06,0.987l0.661,1.147l-0.232,0.611l2.516,1.49l0.94,1.787l-0.245,2.204l-1.812,3.965l0,0l-0.267,1.655l0.884,1.632l0,0l3.794,1.488l2.239,-0.304l0,0l1.19,-0.311l0,0l2.95,-1.087l2.193,1.084l2.289,0.27l0,0l2.235,2.177l0,0l1.661,1.234l2.454,-0.049l3.483,-2.492l0,0l1.52,-0.375l0,0l2.416,0.891l1.076,-0.593l0.805,-3.582l0.777,-1.001l0.3,-0.217l0.972,0.013l0,0l0.691,1.275l-0.467,3.045l0,0l0.787,2.369l0.895,1.29l2.114,1.687l0,0l0.939,1.081l1.382,0.7l0,0l5.868,-1.104l0,0l3.434,0.771l3.992,1.97l0,0l1.917,0.572l1.563,-0.56l3.938,-3.265l1.011,0.297l0,0l1.135,-0.438l1.802,-2.29l0,0l2.017,-1.413l0,0l2.101,0.042l0,0l1.333,0.103l1.591,0.768l0,0l1.282,0.704l0,0l2.414,0.864l0,0l0.958,-0.353l0,0l0.769,-0.789l0,0l1.466,2.421v1.465l-1.198,1.047l0,0l-2.226,1.886l0.342,4.814l2.226,1.047h2.739l0,0l2.396,0.208l3.253,3.348l0,0l3.423,3.974l2.226,1.882l0,0l3.082,0.208l0,0l1.264,1.544l0,0l-2.943,2.706l-0.572,1.857l-4.857,0.571l-1.714,2.571l-0.856,2.714l-1.029,1.339l-1.832,-0.316l-3.943,2.476l-0.977,1.162l-0.791,0.198l-0.857,1.999l-1.429,1.572l-4.143,0.143l-3.856,2.428l-2.286,0.287l-0.429,4.998l-4.286,1.144l-2.428,1.001l-0.2,0.464l0,0l-1.807,2.223l-0.971,-0.733l0.157,1.245l-1.205,0.096l-1.048,-0.765l-0.654,1.05h-0.473l-0.367,-0.732l-0.865,0.191l-0.052,-0.925l-1.231,-0.031l0.105,0.511l-0.707,0.318l-0.708,-0.733l-0.211,-0.479l0.892,-0.414l0.813,-1.308l-0.654,-0.765l0.052,-1.054l-0.864,-0.287l0.209,-0.988l-1.676,0.798l0.523,1.754l-1.18,0.957l-0.341,-1.532l-1.781,-0.732l-0.156,-0.765l0.444,-0.575l-1.834,0.319l-0.42,1.723l-0.627,-0.829l-0.839,0.255l0.76,-1.085l-0.655,-1.021l0.185,-0.861l-0.552,0.225l-0.969,-1.309l-0.21,-3.225l1.625,-1.213l1.441,-0.159l0.865,-0.989l-1.232,0.733l-2.96,0.607l-2.201,2.585l0.472,1.245l0.917,0.351l-0.628,0.605l0.341,0.702l0.577,-0.319l0.549,0.448l0.943,2.105l-0.34,0.541l-1.022,0.287l-0.812,-0.287l-0.13,0.702l1.021,0.351l0.812,-0.511l0.68,0.096l-0.313,0.927l0.366,2.455l2.438,1.944l0.025,0.286l-2.28,0.351l0.786,0.957l1.363,-0.319l0.837,0.319l0.028,0.381l-2.804,1.148l-3.119,0.605l0.551,-0.892l0.866,-0.255l0.338,-1.053l-0.338,-0.064l-0.42,0.893l-0.314,-0.414l-1.65,0.224l0.575,1.369l-0.47,0.319l-0.734,-0.16l-1.283,-1.815l2.227,-0.158l-0.314,-1.212l0.968,-0.67l0.892,-0.063v-0.384l-3.772,-1.146l0.603,-0.733l-0.367,-0.351l-0.499,0.319l-0.079,-1.436l-1.022,1.818l-0.524,-0.16l-1.021,0.796l-0.629,0.033l-0.863,-0.926l-1.022,-0.285l0.104,0.828l-1.022,0.414l-1.416,-0.828l-0.863,-0.064l-0.21,1.053l2.96,1.72v0.385l-0.418,0.352l-0.655,-0.736l-0.418,0.958l-2.098,0.191l-1.31,1.942h-1.153l0.052,-0.828l-0.394,-0.064l-1.099,0.99l-1.545,0.381l-0.08,0.542l-0.759,-0.413l0.708,1.593l-0.839,0.669l-0.392,-0.191l0.131,0.892l-1.127,0.859l0.026,0.668l0.839,-0.731l1.887,-0.351l0.105,-1.752l1.493,-0.892l4.061,-1.02l-0.577,-0.987l0.393,-1.021l0.788,-0.191l0.393,0.828l0.891,-0.509l0.078,-0.925l1.258,1.307l-0.445,0.861l0.393,0.349l-0.262,0.894l-1.338,-0.35l-0.444,0.284l0.707,0.511l1.31,0.16l0.394,0.573l-0.419,0.827l1.861,0.893l0.105,0.605l-0.918,1.242l-0.365,-0.637l-0.472,0.096l0.13,1.177l-0.708,0.097l-0.026,0.668l-1.284,-0.508l0.342,0.891l-0.394,0.127l-2.175,-0.731l-3.013,-0.064l0.026,1.434l0.865,-0.51l1.075,0.095l1.205,0.383l0.236,1.05l-0.997,1.4l-0.943,0.541l0.576,0.254l0.08,1.084l-0.498,0.604l0.996,0.891l-0.654,0.447l0.077,1.304l-1.1,0.763l0.787,0.763l-0.603,0.765l0.393,1.526l-0.21,1.238l0.918,-0.667l0.262,-0.508l-0.341,-0.129l0.079,-0.508l1.441,-1.431l-0.131,-0.699l-0.629,-0.445l0.158,-0.318l1.232,-0.096l0.655,1.112l-0.08,0.573h0.447l0.078,0.827l0.812,-0.097l0.157,0.352l-0.76,2.287l-0.681,-0.221l-0.368,-1.113l-0.314,0.921l0.314,1.019l-0.864,-0.128l0.628,0.859l-0.131,1.398l-1.676,1.017l-0.813,-0.286l-1.441,0.636l2.751,0.635l0.237,0.922l-0.262,0.572l0.234,1.493l-0.891,-0.286l-0.103,0.444l0.812,0.858l-0.578,0.539l-1.31,-0.254l1.52,1.208l-1.022,1.333l-0.13,0.89l-1.678,-0.095l-0.235,-0.637l-0.576,0.35l-0.079,-1.684l-0.211,-0.19l-0.601,0.572l-0.211,-0.539l0.498,-0.636l-0.839,-1.208l-0.627,0.954l-0.184,-0.604l-0.943,-0.16l0.787,-0.888l0.706,-0.064l-0.365,-0.539l0.314,-0.731l-2.986,-1.207l-1.049,0.952l-0.576,-1.048v-0.444l0.342,0.35l0.575,-0.318l-0.236,-1.429l0.498,0.094l0.157,1.018l0.498,-0.286l-0.157,-0.731l0.604,-0.158l0.47,0.35l-0.13,0.571l0.734,0.509l0.629,-0.54l1.232,2.511l-0.184,-1.748l0.995,0.317l0.943,-0.762l-0.47,-0.287l-0.629,0.605l-0.237,-0.637l-0.549,0.063l0.418,-0.858l-1.31,0.095l0.314,-0.476l-0.682,-0.668l0.76,-0.096l0.969,-1.271l2.254,0.476l0.655,-0.35l-0.341,-0.604h-2.804l-0.497,-0.667l0.314,-1.018l-0.367,-0.668l-0.289,0.7l-0.786,-0.415l0.629,1.463l-0.341,0.414l-1.572,-0.318l-0.473,-1.685l-0.209,1.558l-0.655,-0.19v-0.826l-0.76,-0.097l0.367,0.605l-0.891,0.19l-0.026,-1.24l-1.074,0.795l-0.629,-1.463l-1.152,-0.858v-0.382l1.389,-0.7h2.489l0.785,0.478l0.787,-0.35l-0.313,-0.509l0.288,-0.668l-0.681,-0.064l-0.156,-0.254l0.365,-0.159l-0.601,-0.572l0.182,-0.859l-0.471,-1.527l-0.472,0.445l-0.55,-0.255l0.208,-1.081l-0.339,0.159l-0.971,-0.797l0.183,1.178l-0.34,0.127l0.445,0.7l-0.419,0.065l-0.182,0.604l-1.417,0.223l0.473,2.068l-1.415,1.019l-0.707,-0.733l0.026,1.4l-0.577,-0.031l-0.026,-0.669l-0.942,-0.224l0.236,-0.667l-0.629,-0.509l0.732,-1.368l-0.314,-0.668l-0.628,-0.096l-0.367,0.446l-0.655,-0.604l-0.288,0.699l-0.025,-0.859l-0.578,-0.189l-1.048,0.508l-0.578,-0.604l-0.418,0.826l-0.524,-0.412l-0.183,0.444l-0.315,-0.285l-0.997,0.443l0.788,1.273l-0.498,1.241l0.314,2.449l-1.887,-0.159l-0.655,-1.399l-0.208,1.209h-0.735l-0.68,-1.209l-1.6,0.572l-0.865,1.559l-0.994,-1.846l-1.049,0.255l-0.733,-1.018l0.602,-0.891l0.657,-0.159l0.183,0.54l0.237,-0.795l-4.14,-0.445l-0.104,0.382l-2.07,-0.699l-1.363,-1.241l-0.026,-0.699l-0.917,-1.338l1.808,-1.369l0.367,-0.953l-0.76,-0.384l-0.578,-1.688l1.022,-2.323l-0.419,-0.797l-0.733,0.638l-0.158,-0.51l0.604,-1.02l-0.262,-1.211l0.942,-3.218l1.153,-0.988l-0.629,-0.32l-2.018,1.53l0.21,0.607l-0.917,0.859l0.393,1.052l-0.315,1.529l-0.549,0.605l-1.074,-0.256l-0.341,-0.477l1.178,-0.639l-0.235,-0.7l-0.026,0.446l-0.706,0.414l-0.316,-0.605l-1.729,-0.318l-0.498,1.243l-0.393,0.095l-0.026,0.286h0.865l0.236,-0.796l0.838,0.158l-0.157,0.67l1.284,1.052l-0.131,1.083l1.127,0.254l-0.394,2.229l-0.706,-0.414l0.051,1.527l-0.444,-0.19l0.183,-0.508l-0.708,-0.893l-0.446,0.16l0.131,1.146l-0.419,-0.573l-0.419,0.19l0.551,0.733l-0.865,0.444l-1.127,-2.165l-0.785,0.192l-0.472,1.178l-0.445,-0.224l-0.472,0.318l0.497,0.859l-1.493,-0.54l0.367,-0.827l-0.604,0.221l-0.262,-0.636l0.314,-0.51l0.445,0.287l0.079,-1.242l-0.707,-0.19l-0.839,-1.242l-0.472,0.699l0.288,0.733l-0.629,1.401l0.21,0.986h-0.918l0.394,1.242l-0.996,0.127l-0.499,0.986l0.184,0.351l-0.733,0.573h-0.734l-0.366,0.764l-1.442,0.191l-0.445,-0.447l-1.048,0.447l-0.236,-1.528l-0.419,-0.254l-0.157,0.636l-0.551,-0.859l-0.418,2.101l-0.499,0.318l-0.471,-0.731l-0.749,0.158l-0.091,-0.451l-0.694,-0.321l0.036,-2.928l-1.572,-4.104l0,0l-1.741,-1.326l0,0l-1.177,-1.868l-1.613,-0.686l-0.765,-1.237l0,0l-1.09,-1.043l0,0l-0.194,-2.896l-3.036,-3.632l-2.219,-1.127l-1.296,-1.687l-0.905,-9.198l-2.654,-2.981l0.016,-1.559l0.783,-0.696l0,0l0.229,-0.204l0,0l2.211,-2.3l-0.549,-2.862l0.337,-1.157l0.817,-1.982l3.695,-3.56l0.554,-3.456l0,0l-0.099,-0.544l0,0l-1.629,-0.427l0,0l-0.69,-1.924l0,0l0.685,-3.334l0,0l-1.267,-2.267l0,0l-0.501,-1.046l0.08,-1.854l0,0l-0.694,-0.701l-2.073,-0.668l0,0l-0.17,-2.312l0,0l1.585,-3.273l0,0l0.784,-4.727l0,0l1.901,-4.932l0.94,-1.447l0,0l0.891,-0.796l0.155,-1.913l0,0l0.78,-4.811l1.669,-1.143l3.26,-3.585l0.806,-2.281l0,0l0.668,-1.204l0,0l0.181,-0.582l0,0l0.206,-0.637l0.443,0.164l0,0l0.709,0.494l0,0l1.303,-0.056l0,0l1.822,-1.146l0,0l1.458,-0.009l1.778,-1.644l1.321,-0.237l0.537,-1.933l1.506,-2.68l2.32,-1.511l0.128,1.934L239.305,487.755zM325.062,579.521l0.395,0.063l0.104,1.369l1.021,-0.285l0.471,1.752l-1.624,3.408l0.655,0.795l-0.576,1.434l-0.733,0.413l0.262,-0.603h-0.76v-0.766l-0.342,-0.191l0.131,-0.795l0.684,-0.414l-2.045,-0.893l-0.078,-0.383l0.653,0.064l0.368,-0.478l-0.761,-0.605l0.446,-0.191l-0.054,-0.67l-0.522,-0.701l-0.762,-0.126l-0.13,-0.702l0.865,-0.284l0.026,-0.384l1.57,-0.095l0.132,-0.67L325.062,579.521zM310.782,582.516l0.732,0.287l0.446,0.859l0.76,-0.096l-0.053,-0.542l0.525,0.51h0.785L314.87,585l-0.865,1.656l-0.55,-0.446l-0.498,0.35l-0.104,0.383l0.523,0.19l0.079,0.478l-1.362,0.064l0.183,0.604l0.604,-0.095l-0.524,1.146l0.131,1.083h0.654l0.395,0.891l0.89,0.032l-0.183,0.827l0.367,0.765l0.654,0.19l0.131,1.146l-0.419,0.223l-0.445,-0.317l0.025,2.162l0.524,0.765l-0.367,0.508l-0.891,-0.287l0.629,1.305l-0.969,0.158l-0.342,0.701l-0.681,0.287l-0.054,1.048l1.442,0.287l-0.445,0.636l0.341,0.255l0.76,-1.464l1.1,-0.762l0.97,0.57l1.179,-1.048l-0.864,1.207l0.158,0.479l-0.577,0.095l0.446,1.24l-0.655,0.698l-0.944,-0.539l-0.262,0.254l1.152,2.385l-1.126,0.284l-0.576,-0.984l-1.599,1.049l0.026,0.89l0.629,0.541l0.864,-1.018l0.734,0.541l0.104,0.572l-0.708,0.508l1.992,3.366l0.025,0.763l-0.497,0.097l-0.498,-0.764l-1.888,-0.19l-0.025,-0.413l0.577,-0.381l-0.76,-1.365l-0.97,0.634l0.105,1.207l-0.289,0.064l-0.682,-0.19l0.341,-0.483l-0.131,-0.756l-2.069,-0.445l-0.235,2.288l0.707,0.857l-1.441,1.271l-1.18,-0.445l-0.732,1.777l1.387,2.382l1.967,-0.253l0.732,0.444l0.13,0.412l-0.627,0.127l0.026,0.857l-0.524,-0.826l-1.415,-0.508l-0.392,0.635l-1.182,-0.189l-0.917,0.571l-0.182,-0.699l-0.472,0.762l0.838,1.207l0.813,0.221l0.235,0.54l-0.394,0.381l-0.629,0.032l-0.576,-0.508l-1.493,1.459l-1.808,-0.92l-1.284,0.761l-0.159,-0.54l0.499,-0.981l0.734,-0.096l-0.289,-0.667l1.754,-0.477l0.315,-0.507l-0.578,-0.698l-1.361,0.063l-0.892,-0.477l0.027,-1.269l0.445,-0.509l-0.262,-0.667l2.043,-0.158l-0.051,-0.444l-0.812,-0.317l0.497,-0.858l-1.415,0.287l-0.707,-0.351l-1.232,1.398l-0.76,-0.19l-0.078,-0.891l1.415,-1.396l-0.996,-0.159l-1.39,1.556l0.237,-1.047l-0.656,-0.382l0.969,-0.159l0.237,-0.539l1.991,0.032l1.179,-0.509l0.025,-2.287l1.049,-0.858l-0.079,-0.762l-0.708,0.189l-0.183,-0.856l-0.656,-0.191l-0.156,-0.479l1.048,0.318l0.026,-0.698l-1.441,-0.825l-0.97,1.334l0.157,1.144l-2.332,-0.285l-0.21,0.698l-0.758,-0.444l-0.472,0.634l0.366,0.731l-0.759,-0.253l0.366,0.92l-0.655,0.764l-0.603,-0.032l-0.13,-0.984l-0.812,-0.699l0.68,-0.858l-1.206,-0.158l-1.257,-0.922l-0.367,-0.89l0.262,-0.35l-0.629,-0.383l0.367,-0.35l-0.524,-1.747l0.419,-1.271l0.76,-0.541l0.707,-1.336l0.813,-0.063l-0.393,-0.699l0.812,0.35l-0.471,-0.795l0.603,0.413l0.837,-0.222l-0.026,-0.637l0.945,-0.923l0.917,0.19l0.968,0.859l0.028,0.54l1.938,1.21l0.917,-0.159l0.052,-0.414l-0.602,-0.509l1.441,-0.764l0.523,0.827L303,597.54l0.209,0.669l0.787,-0.382l0.68,1.43l0.997,0.318l0.052,-0.731l-0.892,-1.462l0.262,-0.636l-0.995,0.286l0.262,-1.051l-0.708,-0.096l-0.786,-1.877l-0.917,-0.287l0.342,-1.048l0.417,0.413l0.524,-0.573l-0.13,-1.368l0.733,-0.511l0.471,0.287l-0.499,1.082l1.127,-0.637l1.469,0.287l-0.027,-0.636l0.891,0.891l0.733,0.158l0.288,-0.317l-0.55,-0.224l0.105,-1.113l0.498,-0.892l0.575,-0.224l-0.498,-0.063l-0.051,-0.668l1.048,-0.255l-0.499,-0.796l0.734,0.352l0.341,-0.479l0.394,0.987l0.602,0.031l-0.732,-1.306l0.838,-0.159l-0.105,-0.573l-0.419,0.414l-0.891,-0.286l0.392,-1.656l0.395,-0.063l-0.025,-1.274l0.892,-0.128l-0.866,-0.572L310.782,582.516zM307.979,584.681l0.473,1.243l-0.656,1.241l-0.053,0.414l0.578,0.159l-0.63,0.063l-0.053,1.72l-1.728,0.383l0.288,-0.415l-0.788,-0.285l-0.392,0.891l-0.76,0.19l0.209,-1.4l0.446,-0.223l0.183,0.317l0.734,-0.923l-0.079,-0.286l-0.918,0.031l0.105,-0.51l1.572,-0.031l-0.235,-1.114l0.629,-0.765l0.523,0.383L307.979,584.681zM236.683,593.309l0.55,0.542l0.891,-0.031l0.078,0.444l0.472,-0.35l0.21,0.667l0.183,-0.795l0.629,0.286l-0.393,0.638l0.707,2.13l-0.471,1.56l0.157,1.24l-0.577,-0.031l-0.944,0.954l-0.707,-0.096l-0.34,1.493l0.996,2.226l0.628,0.445l-0.577,0.922l1.468,1.048l0.708,-0.285l0.996,0.668l0.157,2.128l0.917,0.444l0.786,-0.189l0.339,-0.319l-0.68,-0.54l1.808,-0.698l-0.104,-0.667l1.231,-0.699l2.673,0.19l0.052,-0.317l0.995,-0.159l0.394,0.827l1.074,0.571l0.235,-0.382l1.179,0.477l0.551,0.954l-0.472,0.92l0.392,0.445l-0.446,0.316l-0.733,-0.253l-0.13,0.636l0.602,0.317l-0.761,1.207l0.866,3.523l-0.262,0.699l-0.654,0.189l-1.232,1.303l-0.182,0.825l2.488,1.776l-0.655,-0.316l-0.025,0.443l-0.604,0.064l-0.393,0.633l-0.733,-0.127l0.131,-0.477l-0.865,-0.029l-0.236,0.792l-0.498,-0.159l0.654,-1.936l-0.942,-0.603l-0.786,0.286l0.313,0.699l-0.235,0.38h-0.471l-0.262,-0.508l-0.787,0.317l-0.34,-0.825l-0.472,0.286l0.393,0.697l-0.393,0.444l-1.101,-0.317l-1.468,0.254l-0.393,-0.856l0.472,-0.19l-0.052,-0.477l-0.655,-0.222l-0.604,-2.538l0.393,-2.097l0.656,-0.889l-0.419,-0.539l-2.097,0.189l-2.253,1.144l0.707,3.683l-0.498,0.73l-1.624,0.602l-2.988,-0.635l0.419,-0.729l-1.074,-0.412l0.524,-0.54l-0.34,-0.666l-1.494,-0.095l-0.157,-0.858l0.577,-0.127l0.209,-0.604l-0.262,-0.538l1.074,-0.255l-0.602,-1.999l-0.734,-0.256l-0.366,-0.699l0.235,-1.429l-0.838,-0.317l0.053,-0.73l-1.389,-1.843l-0.576,-2.83l0.97,-0.89l-0.21,-0.73l0.289,-0.349l0.97,-0.064l-0.184,-0.89l0.602,-0.923l-0.34,-0.318l0.996,-0.542l0.184,-0.856l0.393,0.604l1.65,-0.223l-0.969,-1.271v-0.86h0.523l-0.419,-0.699l1.075,-0.382l-0.08,-0.572l0.498,-0.668L236.683,593.309zM249.6,596.077l0.236,0.7l-0.707,1.686l-0.89,0.827l-0.551,3.147l1.284,0.286l-0.13,-2.067l1.311,-1.749l0.994,0.129l0.211,1.59l0.603,-0.256l1.074,1.306l-0.131,1.397l-0.76,0.254l-0.339,0.795l0.758,-0.317l0.263,0.73l-0.394,0.445h1.443l0.026,0.699l0.891,0.254l0.157,0.985h-0.865l-0.498,-0.857l-0.733,0.604l-0.97,-0.954l-0.785,0.318l-2.28,-1.525l-0.314,1.207l-1.389,0.318l-1.624,-0.063l-1.651,-0.826l0.261,-0.35l-0.759,-0.731l-0.237,-1.176l0.184,-0.954l1.31,-0.826l0.105,-0.826l1.152,-0.924l0.052,-1.049l0.682,-0.954l1.756,-1.05l0.576,0.19L249.6,596.077zM265.637,603.201l2.305,0.984l0.759,0.795l-0.261,0.317l-2.227,-0.095l-0.576,0.413l-0.473,1.239l-0.969,0.381l-0.55,-0.763l0.418,-0.54l-1.284,-0.317l-0.288,-1.335L265.637,603.201zM269.094,605.393l1.258,1.971l1.493,0.89l-0.55,0.794l-2.017,-0.189l0.576,1.143l-0.313,0.731l-0.474,-0.763L267.811,610l-0.026,-0.793l-1.257,0.063l-0.131,-0.382l0.683,-0.159l-0.186,-0.317l-1.361,-0.381l0.157,-0.795l0.393,0.413l0.812,-0.03l-0.654,-0.604l0.865,-1.24L269.094,605.393zM292.441,608.063l0.104,0.318l-0.707,0.381l0.367,0.413l0.104,-0.445l0.419,0.032l-0.235,0.54l0.68,0.763l0.105,2.128l1.207,-0.254l0.55,0.825l-0.315,1.175l-1.885,1.111l-0.656,-0.508l-1.337,0.063l0.367,-0.254l-0.367,-0.635l0.577,-0.254l-1.337,-1.779l0.315,-0.539l-0.079,-1.748l0.523,0.572l-0.051,1.207l0.759,-0.381l-0.158,-1.048l1.127,0.635l-0.682,-1.016l-0.865,0.253l-0.288,-0.73l0.288,-0.826H292.441zM269.882,626.916l1.204,0.951l0.655,-0.222l0.996,0.824l-0.237,0.571l-0.759,0.126l0.681,0.316l0.263,0.635l0.943,-1.648l1.335,-0.032l-0.549,0.54l0.288,0.379l-0.812,0.445l0.157,0.919l-1.651,-0.096l-0.078,-0.476l-0.761,-0.284l-0.683,0.886l-1.073,0.033l-0.158,0.919l-0.891,-0.159l-0.262,-0.57l1.075,-0.189l0.053,-0.507l-0.788,-0.571l0.262,-0.762l-0.864,0.509l-0.446,-0.73l1.102,-0.38l-0.681,-0.983l0.549,-0.412L269.882,626.916z"/>
			        <path id="KR-49" title="39000" class="land" d="M148.226,754.688l0.681,0.781l-0.445,0.596l0.786,-0.314l0.656,0.22l-0.524,0.531l0.393,1.157l-0.551,1.221l-2.07,-0.5l-0.445,-1.439l0.786,-1.971L148.226,754.688zM143.614,769.785l-1.442,0.531l-1.703,1.749l-0.472,2.025l-2.463,2.47l0.157,1.436l-1.31,1.468l-2.122,0.469l-2.936,-0.563l-3.118,3.245l-2.411,0.155l-3.799,1.062l-0.759,-0.406l-2.018,0.312l-2.673,2.152l-0.079,0.779l-1.808,0.687l-0.864,-0.374l-0.132,-0.53l-1.703,-0.063l-0.524,1.279l-1.467,-0.873l-2.149,0.187l-1.598,0.811l-3.694,0.841l-1.1,-1.684l-0.734,-0.154l-2.332,0.623l-1.336,-1.061l-0.524,0.062l-3.301,1.498l-4.219,-1.122l-3.092,2.026l0.026,2.96l-0.55,0.156l-0.314,-0.623l-0.524,-0.03l-0.944,0.622l-0.89,-0.592l0.235,-1.122l-0.838,-0.031l-2.122,-2.869l-2.987,-1.276l-1.886,-1.561l-1.834,-2.995l0.577,-3.307l-0.577,-1.811l0.419,-0.78l1.363,-0.687l0.026,-1.405l2.751,-1.779L79,769.879l1.206,0.188l2.175,-2.5l0.445,-2.812l4.193,-1.688l0.079,-1.688l0.367,-0.281l1.939,-0.033l1.886,-0.529l0.236,-0.532l1.309,0.063l1.651,-1.345l0.472,-0.031l0.708,0.782l1.153,-0.876l4.139,-1.094l1.258,-1.002l1.337,-0.094l0.34,-0.813l0.733,-0.407l2.018,0.597l1.257,-0.221l1.153,-0.751l0.97,0.438l1.257,-0.688l2.07,0.157l0.786,-1.158l3.694,-0.251l0.105,-0.813l0.996,-1.189l1.887,1.503l0.865,-0.282l0.235,-0.846l0.866,0.345l3.773,-1.251l3.17,0.374l0.236,-0.938l3.013,0.595l0.314,0.532l1.834,-0.596l0.918,0.095l0.104,1.409l1.206,1.596l1.074,0.094l0.681,0.845l0.996,-0.626l2.201,0.282l1.048,0.749l-0.418,1.314h1.021l0.341,0.939l-0.157,1.313l-0.813,0.094l-0.184,0.751l1.809,1.438l1.337,-0.5l0.131,0.875l0.943,0.813l-0.472,0.562l-0.996,-0.654l-0.812,1.219l-0.105,1.03l1.494,1.094l-0.734,0.876l-0.629,-0.501l0.262,-0.469l-0.865,-0.343L143.614,769.785z"/>
			        <path id="KR-50" title="29000" class="land" d="M180.84,395.146L182.397,397.326L182.086,400.128L179.906,400.751L182.709,404.176L182.709,406.979L183.159,408.328L186.491,408.523L186.398,409.979L185.573,411.799L186.651,412.939L184.789,419.024L185.367,418.243L185.766,417.918L186.472,418.063L187.087,418.922L187.396,418.957L187.068,422.235L186.134,425.039L182.709,426.596L181.798,426.639L179.283,427.218L179.596,435.937L177.416,438.428L175.713,436.376L173.965,435.031L172.754,431.937L172.888,427.902L172.619,425.077L171.274,421.176L168.583,419.697L166.7,417.141L166.566,415.123L167.642,412.702L167.642,409.608L167.507,406.11L167.239,402.747L167.911,400.326L167.642,397.231L167.104,395.215L166.028,393.197L166.431,391.447L169.122,390.371L171.677,391.178L173.157,392.793L175.848,394.407L178.403,395.348z"/>
			    </g>
			</svg>        
        </div>
        <div class="svgBoxInner2">
		    <div name = "fireCnt" id = "fireCnt"></div>
		    <div name = "fireAmount" id = "fireAmount"></div>
		    <div name = "result" id = "result"></div>
        </div>    
    </div>
	<!-- 통계 테이블 -->
	<div>
	    <div class="d-grid gap-2 d-md-flex justify-content-md-end">
			<button type="button" id="CSV" class="btn btn-download me-1 d-none">내려받기</button>
	    </div>
	    <table id="table" class="table table-bordered table-striped table-hover table-sm mt-3">
	        <thead id="thead" style="text-align: center;"></thead>
	        <tbody id="tbody"></tbody>
	    </table>
	</div>
</section>


<jsp:include page="/WEB-INF/views/footer.jsp" />
<script src = "${CP}/resources/js/bootstrap.bundle.min.js"></script>        
</body>
</html>