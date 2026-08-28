/*
 * Copyright 2012-2025 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.springframework.samples.petclinic.integration;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.restclient.RestTemplateBuilder;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.RequestEntity;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;

/**
 * Cross-component integration suite: the contract the mobile client depends on the
 * Payments API to honour.
 * <p>
 * This is the only suite in the repository that asserts something about <em>both</em>
 * components, which is why its report is attested by the release pipeline rather than by
 * either component's build. The mobile client has no source here (see
 * {@code mobile-client/README.md}), so its half of the contract is expressed as the set
 * of endpoints it calls rather than as code that calls them.
 * <p>
 * Named {@code *IT} so Surefire's default includes skip it: the component build must not
 * run the cross-component suite. It is executed by Failsafe under the {@code integration}
 * Maven profile — {@code ./mvnw -P integration verify}.
 */
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class MobileClientContractIT {

	@LocalServerPort
	int port;

	@Autowired
	private RestTemplateBuilder builder;

	@Test
	@DisplayName("owner list is reachable for the mobile client")
	void ownerListEndpointServesTheMobileClient() {
		assertThat(statusOf("/owners?lastName=")).isEqualTo(HttpStatus.OK);
	}

	@Test
	@DisplayName("owner detail is reachable for the mobile client")
	void ownerDetailEndpointServesTheMobileClient() {
		assertThat(statusOf("/owners/1")).isEqualTo(HttpStatus.OK);
	}

	@Test
	@DisplayName("vet directory is reachable for the mobile client")
	void vetDirectoryEndpointServesTheMobileClient() {
		assertThat(statusOf("/vets.html")).isEqualTo(HttpStatus.OK);
	}

	/**
	 * Issues a GET and returns the status, treating an error status as a result rather
	 * than an exception. Without this a 404 would surface as an
	 * {@link HttpStatusCodeException} and the report would record an {@code error} with a
	 * stack trace, where what this suite means is a {@code failure}: the endpoint
	 * answered, just not the way the contract requires.
	 */
	private HttpStatusCode statusOf(String path) {
		RestTemplate template = this.builder.baseUri("http://localhost:" + this.port).build();
		try {
			return template.exchange(RequestEntity.get(path).build(), String.class).getStatusCode();
		}
		catch (HttpStatusCodeException ex) {
			return ex.getStatusCode();
		}
	}

}
