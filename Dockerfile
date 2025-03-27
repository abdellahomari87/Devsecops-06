FROM openjdk:8
ADD jarstaging/com/omari87/demo-workshop/2.1.2/demo-workshop-2.1.2.jar sample_app.jar 
ENTRYPOINT [ "java", "-jar", "sample_app.jar" ]
