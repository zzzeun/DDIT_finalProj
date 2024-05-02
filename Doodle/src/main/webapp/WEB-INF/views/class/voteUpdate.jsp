<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<script type="text/javascript" src="/resources/js/jquery.min.js"></script>
<style>
p{
	margin-bottom:0;
}

input{
	padding:10px 15px;
}
.FreeBoardAll, .questionContainer{
	width: 1400px;
	margin: auto;
	backdrop-filter: blur(10px);
	background-color: rgba(255, 255, 255, 1);
	border-radius: 50px;
	box-shadow: 0px 35px 68px 0px rgba(145, 192, 255, 0.5), inset 0px -6px 16px 0px rgba(145, 192, 255, 0.6), inset 0px 11px 28px 0px rgb(255, 255, 255);
	padding: 50px 80px;
}

.questionContainer {
	margin-bottom: 50px;
}

#surveyAllDelBtn{
	background:#ffd77a;
	color:#333;
}

#goListBtn{
	background: #666;
}
.question{
	background: #111;
	width: fit-content;
	display: inline-block;
	color:#fff;
	padding:0px 5px;
	font-weight: 300;
	font-size:1.2rem;
	margin-bottom:15px;
	margin-top:30px;
}
.default-container p input, .multiple-choice-Survey p input, .ubjective-Survey p input{
	height:45px;
	border: 1px solid #ccc;
	border-radius: 5px;
	
}
.btnAll{
	border:none;
	background: #006DF0;
	border-radius: 80px;
	text-align: center;
	height: 35px;
	color:#fff;
	font-weight: 700;
	padding:0px 15px;
	display: inline-block;
	margin-top: 15px;
}

#btn-Zone{
	position:absolute;
	display: flex;
	justify-content: flex-end;
	z-index: 5;
	right: 50px;
	bottom: 25px;
}

#surveyAdd, .multipleAnswerAddBtn{
	background: #333;
}
#Survey-Zone{
	position: relative;
}
.FreeBoardAll{
	position: relative;
}
#FreeBoardContainer h3{
	font-size: 2.2rem;
	text-align: center;
	backdrop-filter: blur(4px);
	background-color: rgba(255, 255, 255, 1);
	border-radius: 50px;
	box-shadow: 35px 35px 68px 0px rgba(145, 192, 255, 0.5), inset -8px -8px 16px 0px rgba(145, 192, 255, 0.6), inset 0px 11px 28px 0px rgb(255, 255, 255);
	width: 390px;
	padding-top: 35px;
	padding-bottom: 35px;
	margin: auto;
	margin-bottom: 40px;
	-moz-animation: fadein 1s; /* Firefox */
	-webkit-animation: fadein 1s; /* Safari and Chrome */
	-o-animation: fadein 1s; /* Opera */
}
@keyframes fadein {
    from {
        opacity: 0;
    }
    to {
        opacity: 1;
    }
}
@-moz-keyframes fadein { /* Firefox */
    from {
        opacity: 0;
    }
    to {
        opacity: 1;
    }
}
@-webkit-keyframes fadein { /* Safari and Chrome */
    from {
        opacity: 0;
    }
    to {
        opacity: 1;
    }
}
@-o-keyframes fadein { /* Opera */
    from {
        opacity: 0;
    }
    to {
        opacity: 1;
    }

</style>

<script type="text/javascript">

$(function(){
	
	const multiples = document.querySelectorAll(".multiple-choice");

	for(let i=0; i< multiples.length; i++){
		    var answers = multiples[i].querySelectorAll("p.answers");
			if(answers.length >= 3){
				multiples[i].querySelector("button.multipleAnswerDelBtn").style.display="inline-block";
			}
	}
	
	$("#autoBtn").on("click",function(){
		$("#voteQustnrNm").val("투표 제목");
		$("#voteQustnrCn").val("투표 내용");
		document.querySelector("#voteQustnrBeginDt").value = "2024-04-17";
		document.querySelector("#voteQustnrEndDt").value = "2024-04-19";
	});
	
	$("#surveyAllDelBtn").on("click",function(){
		var data = {};
		data.voteQustnrCode = "${voteNdQustnrVO.voteQustnrCode}";
		$.ajax({
			type : 'POST',
			url : '/freeBoard/surveyDeleteAjax',
			data : {"data" : JSON.stringify(data)},
			dataType : 'JSON',
			beforeSend:function(xhr){
				xhr.setRequestHeader("${_csrf.headerName}","${_csrf.token}");
			},
			success : function(result) {
				if(result > 0){
					resultAlert2(result, '투표 삭제', '리스트로 이동합니다.', '/freeBoard/voteList');
				}else{
					alertError("투표 삭제가 실패하였습니다.");
					return;
				}
			}
		});

	});
	
	
	//사용자가 이미 답변한 투표일 때 수정 불가능하게 처리
	if("${answerCnt}" > 0){
		var text = $("input[type='text']");
		var textarea = $("textarea");
		text.attr("readonly",true);
		textarea.attr("readonly",true);
		
		var coment = '';
		coment = "<small style='display:block; position:absolute; top: 27px; left: -265px; font-size: 0.9rem; color: #006df0; font-weight: 400;'>사용자가 이미 답변한 투표은 수정할 수 없습니다.</small>"
		
		$("#btn-Zone").append(coment);
	}


	$("#studentFreeBoardLi").css("display", "block");
	$("#teacherFreeBoardLi").css("display", "block");
	$("#parentFreeBoardLi").css("display", "block");

	var selectBoxVal = $("#selectBox option:selected").val();
	
	//보기 추가 버튼 이벤트
	$("#Survey-Zone").on("click", ".multipleAnswerAddBtn",function(){
		var newHtml = '';
		var multiple = $(this).closest(".multiple-choice");
		var answers = multiple.find("p.answers");
		var delBtn = multiple.find("button.multipleAnswerDelBtn");
		newHtml +='<p class="answers" style="display: flex; justify-content: space-between; margin-bottom: 5px;">'
		newHtml +=		'<span style="font-size: 1.6rem; font-weight: 700;">'+ (answers.length + 1) +'</span>'
		newHtml +=		'<input type="text" style="margin-left: 10px; width: 95%;" class="voteDetailIemCn" name="voteDetailIemCn" data-target="vaild">'
		newHtml +='</p>'
		$(this).closest(".multiple-choice").append(newHtml);
		if(answers.length > 1){
			delBtn.css("display","inline-block");
		}
		
	});
	
	//보기 삭제 버튼 이벤트
	$("#Survey-Zone").on("click", ".multipleAnswerDelBtn",function(){
		var multiple = $(this).closest(".multiple-choice");
		var answers = multiple.find("p.answers");
		var delBtn = multiple.find("button.multipleAnswerDelBtn");
		
		multiple.find(answers).last().remove();
		
		if(answers.length == 3) {
			delBtn.css("display", "none");
		}
	});
	
	//투표 수정 버튼 이벤트
	$("#surveyUpdateBtn").on("click",function(){
		var voteQustnrNm = $("#voteQustnrNm").val();//투표이름
		var voteQustnrCn = $("#voteQustnrCn").val();//투표내용(목적)
		var voteQustnrBeginDt = $("#voteQustnrBeginDt").val();//투표시작날짜

		var voteQustnrEndDt = $("#voteQustnrEndDt").val();//투표종료일
		//투표시작 날짜와 종료날짜 비교를 위한 변수와 조건문
		var voteQustnrBeginDtArr = voteQustnrBeginDt.split('-');
		var voteQustnrEndDtArr = voteQustnrEndDt.split('-');
		var startDateCompare = new Date(voteQustnrBeginDtArr[0], parseInt(voteQustnrBeginDtArr[1])-1, voteQustnrBeginDtArr[2]);
		var endDateCompare = new Date(voteQustnrEndDtArr[0], parseInt(voteQustnrEndDtArr[1])-1, voteQustnrEndDtArr[2]);
		var now = new Date();
		
		now.setTime(new Date().getTime() - (1 * 24 * 60 * 60 * 1000)); //1일전     return d.format("d");
		
		if(startDateCompare.getTime() > endDateCompare.getTime()) {
			alertError("투표 종료일은 투표 시작일의 이전 일 수 없습니다.");
			return;
		}
		
		if(now.getTime() > startDateCompare.getTime()) {
			alertError("투표 시작일은 투표 작성일의 이전 일 수 없습니다.");
			return;
		}
		
		//투표지 등록시 null 체크
		if(voteQustnrNm == null || voteQustnrNm == ''){
			alertError("투표지의 이름을 작성해주세요.");
			return;
		}else if(voteQustnrBeginDt==null || voteQustnrBeginDt==''){
			alertError("투표지 시작일을 선택해주세요.");
			return;
		}else if(voteQustnrEndDt==null || voteQustnrEndDt == ''){
			alertError("투표지 종료일을 선택해주세요.");
			return;
		}else if(voteQustnrCn == null || voteQustnrCn == ''){
			alertError("투표지의 목적 및 내용을 작성해주세요.");
			return;
		}
		
		//투표질문지  null 체크
		var validChk = true;
		$("#Survey-Zone").find("div.questionContainer").each(function(idx, item) {
			$(item).find("input[data-target='vaild']").each(function(idx2, item2) {
				var value = $(item2).val().trim();
				if(value == '') {
					alertError("질문 또는 보기는 모두 필수 입력값입니다.");
					validChk = false;
					return false;
				}
			});
			if(!validChk) return false;
		}); //반복문 끝
		
		//투표 질문지가 null이 아닐경우 수정 시작
		if(validChk) {
			var data = {};
			data.voteQustnrNm = $("#voteQustnrNm").val();
			data.voteQustnrCode = "${voteNdQustnrVO.voteQustnrCode}";
			data.voteQustnrBeginDt = $("#voteQustnrBeginDt").val();
			data.voteQustnrEndDt = $("#voteQustnrEndDt").val();
			data.voteQustnrCn = $("#voteQustnrCn").val();
			
			var qustnrList = [];
			$("#Survey-Zone").find("div.questionContainer").each(function(idx, item) {
				var obj = {};
				obj.voteIemCn = $(item).find("input[name='voteIemCn']").val();
				obj.voteIemSn = $(item).find("input[name='voteIemSn']").val();
				var exLength = $(item).find("input[name='voteDetailIemCn']").length;
				if(exLength > 0) {
					//객관식
					var exList = [];
					var exList2 = [];
					$(item).find("input[name='voteDetailIemCn']").each(function(idx2, item2) {
						exList.push($(item2).val());
					});
					$(item).find("input[name='voteDetailIemSn']").each(function(idx3, item3) {
						exList2.push($(item3).val());
					});
					obj.voteDetailIemCn = exList;
					obj.voteDetailIemSn = exList2;
				}else {
					//주관식
					obj.voteDetailIemCn = null;
				}
				qustnrList.push(obj);
			});
			data.qustnrList = qustnrList;
			console.log(data);
			
			$.ajax({
				type : 'POST',
				url : '/freeBoard/voteUpdateAjax',
				data : {"data" : JSON.stringify(data)},
				dataType : 'JSON',
				beforeSend:function(xhr){
					xhr.setRequestHeader("${_csrf.headerName}","${_csrf.token}");
				},
				success : function(result) {
					if(result > 0){
						resultAlert2(result, '투표 수정 ', '리스트로 이동합니다.', '/freeBoard/voteList');
					}else{
						alertError("투표 수정이 실패하였습니다.");
						return;
					}
				}
			});
		}
	});
	
});
</script>

<!-- 자유게시판 hover효과 js -->
<div id="FreeBoardContainer">
	<h3>
		<img src="/resources/images/classRoom/freeBrd/survey.png" style="width:50px; display:inline-block; vertical-align:middel;">
			투표 수정
		<img src="/resources/images/classRoom/freeBrd/vote.png" style="width:50px; display:inline-block; vertical-align:middel;">		
	</h3>
	<form id="SurveyFrm">
		<div class="FreeBoardAll" style="width: 1400px; margin: auto; margin-bottom:50px;">
			<h2 style="border-bottom: 1px solid #111; padding-bottom:10px;">
				<img src="/resources/images/classRoom/freeBrd/svsetting.png" style="width:40px; display:inline-block; vertical-align:middel;">		
				투표 설정
			</h2>
			<div class="defaultAll" style="display:flex;">
				<ul class="default-container" style="flex:1;">
					<li>
						<p>
							<span class="question">1. 투표의 이름을 작성해주세요.</span>
						</p>
						<p>
							<input type="text" name="voteQustnrNm" id="voteQustnrNm" style="width:90%;" value="${voteNdQustnrVO.voteQustnrNm}">
						</p>
					</li>
					<li>
						<p>
							<span class="question">2. 투표 시작일을 지정해주세요.</span>
						</p>
						<p>
							<input type="date" style="width:90%;padding: 10px 15px;" name="voteQustnrBeginDt" id="voteQustnrBeginDt" value="<fmt:formatDate value="${voteNdQustnrVO.voteQustnrBeginDt}" pattern="yyyy-MM-dd" />"/>
						</p>
					</li>
					<li>
						<p>
							<span class="question">3. 투표 종료일을 지정해주세요.</span>
						</p>
						<p>
							<input type="date" style="width:90%;padding: 10px 15px;"name="voteQustnrEndDt" id="voteQustnrEndDt" value="<fmt:formatDate value="${voteNdQustnrVO.voteQustnrEndDt}" pattern="yyyy-MM-dd" />"/>
						</p>
					</li>
				</ul>
				<ul class="default-container" style="flex:1;">
					<li>
						<p>
							<span class="question">4. 투표의 목적 및 내용을 작성해주세요.</span>
						</p>
						<p>
							<textarea rows="" cols="" id="voteQustnrCn" name="voteQustnrCn"style="border-radius:5px;border:1px solid #ccc;width:100%;height:156px;resize: none;padding: 15px 20px;line-height: 1.2;letter-spacing: -0.5px;">${voteNdQustnrVO.voteQustnrCn}</textarea>
						</p>
					</li>
				</ul>
			</div>
			<div id="btn-Zone" style="padding:20px 25px;">
				<c:if test="${answerCnt == 0}">
					<button type="button" id="surveyUpdateBtn" class="btnAll" style="margin-right:0px; margin-top: 0px; margin-left: 5px;">
						투표 수정
					</button>
				</c:if>
				<button type="button" id="surveyAllDelBtn" class="btnAll" style="margin-right:0px; margin-top: 0px; margin-left: 5px;">
						투표 삭제
				</button>
				<button onclick="history.back()"type="button" id="goListBtn" class="btnAll" style="margin-right:0px; margin-top: 0px; margin-left: 5px;">
						목록으로
				</button>
			</div>
		</div>
		<!-- 수정 투표 폼 시작 -->
		<div id="Survey-Zone">
			<c:forEach var="items" varStatus="status" items="${voteNdQustnrVO.voteQustnrIemVOList}">
				<div class="questionContainer">
					<c:if test="${items.voteQustnrType=='V'}">
						<div class="multiple-choice-Survey">
							<div class="multiple-choice-Survey-Q">
								<p>
									<span class="question">생성할 투표의 주제를 입력해주세요.</span>
								</p>
								<p style="display: flex; justify-content: space-between;">
									<span style="font-size: 1.6rem; font-weight: 700;">주제</span>
									<input type="text" style="margin-left: 10px; width: 95%;" name="voteIemCn" data-target="vaild" value="${items.voteIemCn}">
								</p>
							</div>
							<div class="multiple-choice">
								<p class="multiple-btn-zone">
									<span class="question" style="margin-top:20px;">투표 항목을 입력해주세요.</span>
									<c:if test="${answerCnt == 0}">
										<button type="button" class="btnAll multipleAnswerAddBtn">항목 추가</button>
										<button style="display:none;" type="button" class="btnAll multipleAnswerDelBtn">항목 삭제</button>
									</c:if>
								</p>
								
								<c:forEach items="${voteNdQustnrVO.voteQustnrDetailIemVOList}" var="detail" varStatus="vstatus">
									<c:if test="${items.voteIemSn == detail.voteIemSn}">
										<p class="answers" style="display: flex; justify-content: space-between; margin-bottom: 5px;">
											<span style="font-size: 1.6rem; font-weight: 700;" class="voteDetailIemSn">${detail.voteDetailIemSn}</span>
											<input type="hidden" value="${detail.voteDetailIemSn}" name="voteDetailIemSn">
											<input type="text" style="margin-left: 10px; width: 95%;" name="voteDetailIemCn" data-target="vaild" value="${detail.voteDetailIemCn}">
										</p>
									</c:if>
								</c:forEach>
							</div>
						</div>
					</c:if>
				</div>
			</c:forEach>
		</div>
	</div>
</form>
</div>
