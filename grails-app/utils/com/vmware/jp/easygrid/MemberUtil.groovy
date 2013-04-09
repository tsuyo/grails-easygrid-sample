package com.vmware.jp.easygrid

import org.codehaus.groovy.grails.web.json.JSONObject
import grails.plugins.rest.client.RestBuilder
import org.grails.plugin.easygrid.Filter

class MemberUtil {

	public static final String DEFAULT_ORG = "springsource"
	private static final String API_URL = "https://api.github.com"
	private static def rest = new RestBuilder(connectTimeout:1000, readTimeout:20000)
	private static def cache = [:]
	private static def sizes = [:]

	static def getMemberList(String org = DEFAULT_ORG, def filters = null, String sort = null, order = null, rowOffset = 0, maxRows = 10, boolean flash = false) {
		if (flash || !cache[org]) {
			def resp = rest.get("${API_URL}/orgs/${org}/members")
			if (!resp.json instanceof JSONObject) {
				throw new RuntimeException("JSON object should be returned")
			}
			def members = []
			resp.json.each {
				def member = new Member(it)
				member.github_id = it.id as long
				members << member
			}
			cache[org] = members
		}
		def ret = cache[org]

		// filter
		filters?.each { Filter filter ->
			// println "[TM] ${filter.paramName}"
			// println "[TM] ${filter.paramValue}"
			ret = ret.findAll{ it."${filter.paramName}" =~ "${filter.paramValue}" }
		}
		assert ret != null
		sizes[org] = ret.size()
		if (sizes[org] == 0) return []

		// sort
		if (sort) {
			ret = ret.sort { it."$sort" }
			if (order == "desc") {
				ret = ret.reverse()
			}
		}
		ret[rowOffset..(Math.min(rowOffset + maxRows - 1, ret.size() - 1))]
	}

	static def size(String org = DEFAULT_ORG) {
		if (sizes[org] == null) {
			getMemberList(org)
		}
		sizes[org]
	}
}
