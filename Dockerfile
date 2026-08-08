# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a proprietary
# license that can be found in the LICENSE file.

FROM reg.sighup.io/r/library/java/tomcat:10.1-openjdk-17

COPY target/example-1.0-SNAPSHOT.war "${CATALINA_HOME}/webapps/example.war"
COPY lib/* "${CATALINA_HOME}/lib/"
