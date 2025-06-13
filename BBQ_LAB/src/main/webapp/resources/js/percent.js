
var percentRating = function(){
var $percent = $(".percent-input"),
    $result = $percent.find("output>b");
	
  	$(document)
	.on("focusin", ".percent-input>.input", 
		function(){
   		 $(this).addClass("focus");
 	})
		 
   	.on("focusout", ".percent-input>.input", function(){
    	var $this = $(this);
    	setTimeout(function(){
      		if($this.find(":focus").length === 0){
       			$this.removeClass("focus");
     	 	}
   		}, 100);
 	 })
  
    .on("change", ".percent-input :radio", function(){
    	$result.text($(this).next().text());
  	})
    .on("mouseover", ".percent-input label", function(){
    	$result.text($(this).text());
    })
    .on("mouseleave", ".percent-input>.input", function(){
    	var $checked = $percent.find(":checked");
    		if($checked.length === 0){
     	 		$result.text("0");
   		 	} else {
     	 		$result.text($checked.next().text());
    		}
  	});
};

percentRating();