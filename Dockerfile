FROM openjdk:8
ADD jarstaging/demo-workshop-2.1.2-SNAPSHOT.jar sample_app.jar 
ENTRYPOINT [ "java", "-jar", "sample_app.jar" ]
