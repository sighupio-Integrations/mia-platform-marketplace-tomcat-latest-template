# SSC Tomcat custom plugin template walkthrough

This walkthrough will help you learn how to create a Tomcat microservice using SSC's Tomcat from scratch.

## Create a microservice

In order to do so, access to [Mia-Platform DevOps Console](https://console.cloud.mia-platform.eu/login), create a new project and go to the **Design** area. Once there, select _Microservices_ and go ahead creating a new one: that will take you to the [Mia-Platform Marketplace](https://docs.mia-platform.eu/development_suite/api-console/api-design/marketplace/), where you can find a set of Examples and Templates that can be used to set-up microservices with a pre-defined and tested function.

For this walkthrough select the following template: **SSC Tomcat template**. After clicking on ut you will be asked to give the following information:

- Name (Internal Hostname)
- GitLab Group Name
- GitLab Repository Name
- Docker Image Name
- Description (optional)

You can read more about these fields in the [Manage your Microservices from the Dev Console](https://docs.mia-platform.eu/development_suite/api-console/api-design/services/) section of the Mia-Platform documentation.

Pick the name you prefer for your microservice: in this walkthrough we'll refer to it as **sighup-tomcat-demo**.
Then, fill the other required fields and confirm that you want to create a microservice. You have now generated a _sighup-tomcat-demo_ repository that will be deployed on Mia-Platform's [Nexus Repository Manager](https://nexus.mia-platform.eu/) as soon as the CI build script is successful.

## Save your changes

It is important to know that the microservice that you have just created is not saved yet on the DevOps Console. It is not essential to save the changes that you have made, since you will later make other modifications inside of your project in the DevOps Console.
If you decide to save your changes now, remember to choose a meaningful title for your commit (e.g "created service sighup_tomcat_demo"). After some seconds you will be prompted with a popup message which confirms that you have successfully saved all your changes.
A more detailed description on how to create and save a Microservice can be found in [Microservice from template - Get started](https://docs.mia-platform.eu/development_suite/api-console/api-design/custom_microservice_get_started/#2-service-creation) section of the Mia-Platform documentation.

## Look inside your repository

After having created your first microservice (based on this template) you will be able to access to its git repository from the DevOps Console. You will find the project files in the _src_ folder: we provided a simple starting point for you to start with, but you are free to change it as you prefer. We took care of adding a few useful http endpoints that will be useful to integrate with kubernetes.

The repository also contains a rich _Makefile_, containing additional linters and fixers for other languages (e.g. bash, yaml, markdown): you can find the list of all the available commands by typing `make help` in your terminal.

## Add a new route

Now that you have successfully created a microservice from our SSC Tomcat template you will add a _weather_ route to it.

Create a `src/main/java/io/sighup/WeatherServlet.java` file and add the following code:

```java
package io.sighup;

import java.io.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class WeatherServlet extends HttpServlet {
    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        out.println("{\"message\":\"It's sunny!\"}");
        out.close();
    }
}
```

Then, modify the `src/main/webapp/WEB-INF/web.xml` file to add the following code:

```xml
<servlet>
    <servlet-name>WeatherServlet</servlet-name>
    <servlet-class>io.sighup.WeatherServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>WeatherServlet</servlet-name>
    <url-pattern>/</url-pattern>
</servlet-mapping>
```

Once the two files above are created, you need to build the project and the docker image using the following commands:

```bash
mvn clean package
docker build -t tomcat-example:v0.1.0 .
```

Finally, you can run the docker image locally using the following command:

```bash
docker run --rm -p 8080:8080 tomcat-example:v0.1.0
```

By running the server and visiting the `http://0.0.0.0:8080/example/weather` route, you can also test it's working as expected yourself:

```json
{"message":"It's sunny!"}
```

After committing these changes to your repository, you can go back to Mia Platform DevOps Console.

## Expose an endpoint to your microservice

In order to access to your new microservice it is necessary to create an endpoint that targets it. The _Step 3_ of the [Microservice from template - Get started](https://docs.mia-platform.eu/development_suite/api-console/api-design/custom_microservice_get_started/#3-creating-the-endpoint) section of the Mia-Platform documentation explains in detail how to to do so from the DevOps Console.

For the sake of this walkthrough you will create an endpoint to your _sighup-tomcat-demo_. In order to do so, select _Endpoints_ from the Design area of your project and then create a new one.
Now you need to choose a path for your endpoint and connect it to your microservice. Give the following path to your endpoint: **/weather**. Then, specify that you want to connect your endpoint to a microservice and select _sighup-tomcat-demo_.

## Save your changes once more

After having created an endpoint for your microservice, you should **save the changes** that you have done to your project in the DevOps console, in a similar way to what you have previously done after the microservice creation.

## Deploy

Once all the changes that you have made are saved, you should deploy your project through the DevOps Console: you can do so within its **Deploy** area.
Once there, select the environment and the branch you have worked on and confirm your choices by clicking on the _deploy_ button. When the deploy process is finished, you will be informed by a pop-up message.
The _Step 5_ of the [Microservice from template - Get started](https://docs.mia-platform.eu/development_suite/api-console/api-design/custom_microservice_get_started/#5-deploy-the-project-through-the-api-console) section of the Mia-Platform documentation explains in detail how to correctly deploy your project.

## Try it

If you now run the following command in your terminal (remember to replace `${PROJECT_HOST}` with the actual host of your project):

```shell
curl ${PROJECT_HOST}/example/weather
```

you should see a message that looks like this:

```text
It's sunny!
```

Congratulations! You have successfully learnt how to modify a blank template into an _Hello World_ Tomcat microservice!
