<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!-- 글 내용 줄 개행 처리를 위해 추가 -->
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<% pageContext.setAttribute("newLineChar", "\n"); %>

<html>
<head>

   <meta charset="UTF-8">

   <title>RunWith</title>
   
   <!-- jQuery -->
   <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
   
   <!-- 합쳐지고 최소화된 최신 자바스크립트 -->
   <script src="${pageContext.request.contextPath}/resources/js/bootstrap.min.js"></script>
   
   <!-- 합쳐지고 최소화된 최신 CSS -->
   <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
   
   <!-- 개인 디자인 추가, ?after를 붙이면 기존에 동일한 이름의 파일을 인식하는것이 아닌 새로운 파일을 인식하게 된다. -->
   <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/mainstyle.css">
   <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/mainpage-style.css">
   
   <!-- 여기다가 나만의 새로운 css 만들기 -->
   <style>

 	.tbody {
 		width: 100%;
 	
 	}

    .td{
        
        height:350px;
    }
    
       .borderline {
    	border-bottom:0.5px solid black;
    	margin-top: 10px;
    	margin-bottom: 10px;
    	
    }
    
    .maintitle {
    	margin-left : 30px;
    	margin-top : 20px;
    }
    
  
    
    .headtable {
    
    }

    
    .bottomtable {
    	margin-top:30px;
    
    }
    
    .container{
	width:1200px;
	margin: 0 auto;
	}
 
   </style>
   
</head>
<body>

<%@ include file="../include/header.jsp" %>
	   
	<div class="mainbox" style="background-color: white;">
        <section >
 
            <div class="container"  style="background-color: white;" >
				<div class="row" >
					 <!-- 메인화면 공지사항 상단 -->
			            <a href="#" class="list-group-item active notice-list-top" style="margin-top: 20px;">
			            	<span class="main-notice-title">Q&A</span>
			            </a>
			            
			         <!-- 질문글 상세보기 -->
                     <div class="container my-1" style=" padding-bottom: 30px;">
                       <form action="<c:url value='/question/questionDelete'/>" method="post" name="questionDeleteForm">
                        <div class="row">
                            <div class="qa_content" >
                                    <div class="qa_content_up" style="margin-left:30px;" >
		                                        <div class="qa_title" scope="col" style="width: 100%;  margin-top:10px;">
		                                        	<input type="hidden" id="hidden-questionNo" name="questionNo" value="${question.questionNo}">

		                                        	<h4 style="display:inline-block;"><span style="font-weight: bolder; font-size:24px; color:#74C9DC;"> Q . </span> ${question.questionTitle}</h4>
                                              <c:if test="${ question.questionWriter eq user.userID  || user.commonCODE == 'ADM002' }">
			                                          <a type="submit" id="btn-question-delete" class="btn mb-2" style="display: inline-block; float:right; margin-right:70px;">삭제</a>
                                              </c:if>

		                                        </div>
		                                        
		                                        <div style="margin-top:30px;">
			                                        <div class="qa_writer" style="display: inline-block;">
			                                            <img src="<c:url value='/user/userProfileGet?userNO=${questionWriterNo}'/>" width="40px" height="40px" style="border-radius: 30px; margin-left: 10px; margin-right: -5px;" > 
			                                            <div style="display: inline-block; font-size: 14px; font-weight: bold; font-family: sans-serif; margin-left:15px;">${question.questionWriter}</div>
			                                            <c:if test="${question.questionWriter eq user.userID }">
		                                            		<span style="background:lightgray; font-size:13px; color:#202020; padding:5px; margin-left:10px;">내가 작성한 글</span>
		                                            	</c:if>
			                                            <c:if test="${question.questionWriter eq company.companyID }">
		                                            		<span style="background:lightgray; font-size:13px; color:#202020; padding:5px; margin-left:10px;">내가 작성한 글</span>
		                                            	</c:if>
		                                       		</div>
		                                       		<div style="display:inline-block; float:right; margin-top:10px; margin-right:40px; color:gray;">
				                                        <div style="margin-left:50px;">
				                                        	<span style="color:black; font-style: bold;">조회수</span> ${question.questionViews }
				                                        </div>
				                                        <div style="float:right; margin-top:10px; margin-right:40px; color:gray;" >
				                                            <fmt:formatDate value="${question.questionDate}" pattern="yyyy-MM-dd HH:mm" />
				                                        </div>
				                                        
			                                        </div>
		                                        </div>
                                    </div>

                                    <div class="qa_content_down" style="min-height:300px; margin-top:50px; margin-left:30px; font-size:15px; margin-bottom: 30px;">
                                        
                                        	${fn:replace(question.questionContent, newLineChar, '<br/>')}
                                           
                                    </div>
                            </div>
                           
                             <hr class="borderline" style="margin-bottom:40px;" />
                             <button type="submit" class="btn btn-light mb-2 pull-left">신고하기 </button>
                             <button type="button" id="btn-question-list" class="btn btn-info mb-2 pull-right" style="margin-left:10px;">목록 </button>
                             <c:if test="${question.questionWriter eq user.userID || question.questionWriter eq company.companyID }">
                             	<button type="button" class="btn btn-primary mb-2 pull-right"  style="margin-left:10px;" onclick="location.href='<c:url value="/question/questionModify?questionNo=${question.questionNo}"/>'">수정 </button>
                             </c:if>
                             <button type="button" id="btn-go-answer" class="btn btn-success mb-2 pull-right"  style="margin-left:10px;">답변하기 </button>
                           
                        </div>
                      </form>  
                    </div>
                    </div>
                    
                    <div style="background-color: #FAFAFA;">
                    <form action="<c:url value='/question/answerModify' />" method="post" name="answerDetailForm">
                    	<div id="answerList">
                    	
                    		<!-- ----------------답변 목록---------------- -->
                    
                    	</div>
                    </form>
              		</div>
				
			</div>
			 
        </section> 
        <div>
        
        </div>
 
        
				
			
	   
	   
	    <%@ include file="../include/footer.jsp" %>
	    
	</div>
   
   
  
</body>
</html>


<script>

	
	$(function() {
		 
		
		//답글 목록(상세보기) 시작
		let questionNo = $('#hidden-questionNo').val();
		let strAdd = '';
		
		$.ajax({
			type: 'POST',
			url: '<c:url value="/question/answerList/" />',
			
			dataType: 'json',
			
			data: {
				'questionNo': questionNo,
			},
			
			success: function(result) {
				
				let answerList = result.answerList;
				let answerNoList = result.answerNoList;
				
				console.log(answerNoList);
				
				for(let i = 0; i < answerList.length; i++) {
					
					var timestamp = answerList[i].answerDate;
					var date = new Date(timestamp).toISOString().replace("T", " ").replace(/\..*/, "").slice(0,16);
					
					var content = answerList[i].answerContent.replace(/\n/g, '<br/>');
					
					var ansWriter = answerList[i].answerWriter;
					var answerReader = '${user.userID}';
					var memberNo = answerNoList[i];
					
					
					
					if(ansWriter == answerReader){
						

						strAdd +=
							`
			                    <div class="row" style="background:#FAFAFA; border-top: 1px solid black; padding-top: 10px;">
			                            <div class="qa_content" >
			                                    <div class="qa_content_up" style="margin-left:30px;" >
					                                   <div class="qa_title" scope="col" style="width: 100%;  margin-top:10px;">
					                                   		<input type="hidden" id="hidden-answer-no" name="answerNo">
					                                       	<h4 style="display:inline-block;"> <span style="font-weight: bolder; color:#E8473F; font-size:24px;"> A . </span> ` + answerList[i].answerTitle + `</h4>
					                                       	<a type="submit" id="btn-answer-delete" class="btn mb-2" style="display: inline-block; float:right; margin-right:50px;" data-value="` + answerList[i].answerNo + `">삭제</a>
					                                       	<a type="button" id="btn-answer-update" data-value="` + answerList[i].answerNo + `" class="btn mb-2 answerModify" style="display: inline-block; float:right;">수정</a>
					                                   </div>
					                                   
					                                   <div style="margin-top:30px;">
						                                    <div class="qa_writer" style="display: inline-block;">
						                                        <img src="<c:url value='/user/userProfileGet?userNO='/>` + memberNo + `" width="40px" height="40px" style="border-radius: 30px; margin-left: 10px; margin-right: -5px;" > 
						                                        <div style="display: inline-block; font-size: 14px; font-weight: bold; font-family: sans-serif; margin-left:15px;">` + answerList[i].answerWriter + `님의 답변</div>
						                                            
					                                        </div>
					                                       	<div style="display:inline-block; float:right; margin-top:10px; margin-right:40px; color:gray;">
							                                    <div style="display:inline-block;" >
							                                        ` + date + `
							                                    </div>
						                                    </div>
					                                   </div>
			                                    </div>
			
			                                    <div class="qa_content_down" style="min-height:300px; margin-top:30px; margin-left:30px; font-size:15px; margin-bottom: 30px;">
			                                        
			                                        	` + content + `
			                                           
			                                    </div>
			                            </div>
			                        </div>`; 
					} else if (ansWriter != answerReader) {
						
						strAdd +=
							`
			                    <div class="row" style="background:#FAFAFA; border-top: 1px solid black; padding-top: 10px;">
			                            <div class="qa_content" >
			                                    <div class="qa_content_up" style="margin-left:30px;" >
					                                   <div class="qa_title" scope="col" style="width: 100%;  margin-top:10px;">
					                                   		<input type="hidden" id="hidden-answer-no" name="answerNo">
					                                   		<c:if test="${user.commonCODE == 'ADM002'}">
					                                       	<a type="submit" id="btn-answer-delete" class="btn mb-2" style="display: inline-block; float:right; margin-right:50px;" data-value="` + answerList[i].answerNo + `">삭제</a>
					                                       	<a type="button" id="btn-answer-update" data-value="` + answerList[i].answerNo + `" class="btn mb-2 answerModify" style="display: inline-block; float:right;">수정</a>
					                                       	</c:if>
					                                   </div>
					                                   
					                                   <div style="margin-top:30px;">
						                                    <div class="qa_writer" style="display: inline-block;">
						                                        <img src="<c:url value='/user/userProfileGet?userNO='/>` + memberNo + `" width="40px" height="40px" style="border-radius: 30px; margin-left: 10px; margin-right: -5px;" > 
						                                        <div style="display: inline-block; font-size: 14px; font-weight: bold; font-family: sans-serif; margin-left:15px;">` + answerList[i].answerWriter + `님의 답변</div>
						                                            
					                                        </div>
					                                       	<div style="display:inline-block; float:right; margin-top:10px; margin-right:40px; color:gray;">
							                                    <div style="display:inline-block;" >
							                                        ` + date + `
							                                    </div>
						                                    </div>
					                                   </div>
			                                    </div>
			
			                                    <div class="qa_content_down" style="min-height:300px; margin-top:30px; margin-left:30px; font-size:15px; margin-bottom: 30px;">
			                                        
			                                        	` + content + `
			                                           
			                                    </div>
			                            </div>
			                        </div>`;
					
					
					
					
				}else {
						
						strAdd +=
							`
			                    <div class="row" style="background:#FAFAFA; border-top: 1px solid black; padding-top: 10px;">
			                            <div class="qa_content" >
			                                    <div class="qa_content_up" style="margin-left:30px;" >
					                                   <div class="qa_title" scope="col" style="width: 100%;  margin-top:10px;">
					                                   		<input type="hidden" id="hidden-answer-no" name="answerNo">
					                                       	<h4 style="display:inline-block;"> <span style="font-weight: bolder; color:#E8473F; font-size:24px;"> A .</span> ` + answerList[i].answerTitle + `</h4>
					                                       	</div>
					                                   
					                                   <div style="margin-top:30px;">
						                                    <div class="qa_writer" style="display: inline-block;">
						                                        <img src="<c:url value='/user/userProfileGet?userNO='/>` + memberNo + `" width="40px" height="40px" style="border-radius: 30px; margin-left: 10px; margin-right: -5px;" > 
						                                        <div style="display: inline-block; font-size: 14px; font-weight: bold; font-family: sans-serif; margin-left:15px;">` + answerList[i].answerWriter + `님의 답변</div>
						                                            
					                                        </div>
					                                       	<div style="display:inline-block; float:right; margin-top:10px; margin-right:40px; color:gray;">
							                                    <div style="display:inline-block;" >
							                                        ` + date + `
							                                    </div>
						                                    </div>
					                                   </div>
			                                    </div>
			
			                                    <div class="qa_content_down" style="min-height:300px; margin-top:30px; margin-left:30px; font-size:15px; margin-bottom: 30px;">
			                                        
			                                        	` + content + `
			                                           
			                                    </div>
			                            </div>
			                        </div>`;
					}
						
				}
				
				$('#answerList').html(strAdd);
 				
			},
			
			error: function() {
				alert('답변 글을 불러오는 중 서버오류가 발생했습니다.');
				return;
			}
			
			
			
		}); //답글 목록(상세보기) 끝
		
		
		//답글 수정 이동 버튼 (아직 수정중입니다)
		
		$('#answerList').on('click', '#btn-answer-update', function(e){
			e.preventDefault();
			const target = e.target.getAttribute('data-value');
			
			console.log(target);
			
			$('#hidden-answer-no').val(target);
			
			document.answerDetailForm.submit();
			
		})		
				
		
		//답변글 삭제 처리
		$('#answerList').on('click', '#btn-answer-delete', function(e) {
			
			e.preventDefault();
			const target = e.target.getAttribute('data-value');
			const questionNo = $('#hidden-questionNo').val();
			
			console.log(target);
			
			$('#hidden-answer-no').val(target);
				
				$.ajax({
					type:'POST',
					url: '<c:url value="/question/answerDelete"/>',
					
					data: {	
						'answerNo': target
					},
					success:function(result){
						if(result === 'deleteSuccess') {
							alert("답변 게시글이 정상적으로 삭제되었습니다.");
							location.replace('/question/questionContent/' + questionNo);
						}  else {
							alert("답변 게시글 삭제에 실패했습니다.");
						}
					},
					error:function(){
						alert("답변 게시글 삭제에 실패했습니다. 관리자에게 연락해주세요")
					}
				});// end ajax
		}); //답변글 삭제 처리 끝
		
		
		
		//목록 이동 버튼
		$('#btn-question-list').click(function() {
			location.href='<c:url value="/question/questionList"/>';
		});

	
		//질문글 삭제 버튼 처리
	 	$('#btn-question-delete').click(function() {
	 		
	 		if(confirm('정말 삭제하시겠습니까?')) {
				document.questionDeleteForm.submit();
			}
	 	});
		
	
		//답변글 작성 페이지로 이동 버튼
		$('#btn-go-answer').click(function() {
			const questionNo = $('#hidden-questionNo').val();
			
			location.href='<c:url value="/question/answerWrite/"/>' + questionNo;
		});
		
		
	});	//끝
	
	
	

	



</script>
