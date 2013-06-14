url         = require 'url'

nodeJira    = require '../lib/jira'

describe "Node Jira Tests", ->
    makeUrl = (path, altBase) ->
        base = 'rest/api/2/'
        base = 'rest/greenhopper/2/' if altBase?
        url.format
                protocol: 'http:'
                hostname: 'localhost'
                auth: 'test:test'
                port: 80
                pathname: "#{base}#{path}"


    beforeEach ->
        @jira = new nodeJira.JiraApi 'http', 'localhost', 80, 'test', 'test', 2
        spyOn @jira, 'request'
        @cb = jasmine.createSpy 'callback'

    it "Sets strictSSL to false when passed in", ->
        expected = false
        jira = new nodeJira.JiraApi 'http', 'localhost', 80, 'test', 'test', 2, false, expected
        expect(jira.strictSSL).toEqual(expected)

    it "Sets strictSSL to true when passed in", ->
        expected = true
        jira = new nodeJira.JiraApi 'http', 'localhost', 80, 'test', 'test', 2, false, expected
        expect(jira.strictSSL).toEqual(expected)

    it "Sets strictSSL to true when not passed in", ->
        expected = true
        expect(@jira.strictSSL).toEqual(expected)

    it "Finds an issue", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "issue/1"
            method: 'GET'
        @jira.findIssue 1, @cb
        expect(@jira.request)
            .toHaveBeenCalledWith(options, jasmine.any(Function))

        # Invalid issue number (different than unable to find??)
        @jira.request.mostRecentCall.args[1] null, statusCode:404, null
        expect(@cb).toHaveBeenCalledWith 'Invalid issue number.'

        # Unable to find issue
        @jira.request.mostRecentCall.args[1] null, statusCode:401, null
        expect(@cb).toHaveBeenCalledWith(
            '401: Unable to connect to JIRA during findIssueStatus.')

        # Successful Request
        @jira.request.mostRecentCall.args[1] null,
            statusCode:200, '{"body":"none"}'
        expect(@cb).toHaveBeenCalledWith(null, body: 'none')

    it "Gets the unresolved issue count", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "version/1/unresolvedIssueCount"
            method: 'GET'

        @jira.getUnresolvedIssueCount 1, @cb
        expect(@jira.request)
            .toHaveBeenCalledWith options, jasmine.any(Function)

        # Invalid Version
        @jira.request.mostRecentCall.args[1] null, statusCode:404, null
        expect(@cb).toHaveBeenCalledWith 'Invalid version.'

        # Unable to connect
        @jira.request.mostRecentCall.args[1] null, statusCode:401, null
        expect(@cb).toHaveBeenCalledWith(
            '401: Unable to connect to JIRA during findIssueStatus.')
        
        # Successful Request
        @jira.request.mostRecentCall.args[1] null,
            statusCode:200, '{"issuesUnresolvedCount":1}'
        expect(@cb).toHaveBeenCalledWith null, 1

    it "Gets the project from a key", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "project/ABC"
            method: 'GET'

        @jira.getProject 'ABC', @cb
        expect(@jira.request)
            .toHaveBeenCalledWith options, jasmine.any(Function)

        # Invalid Version
        @jira.request.mostRecentCall.args[1] null, statusCode:404, null
        expect(@cb).toHaveBeenCalledWith 'Invalid project.'

        # Successful Request
        @jira.request.mostRecentCall.args[1] null,
            statusCode:200, '{"body":"none"}'
        expect(@cb).toHaveBeenCalledWith null, body:"none"

    it "Finds a Rapid View", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl("rapidviews/list", true)
            method: 'GET'
            json: true

        @jira.findRapidView 'ABC', @cb
        expect(@jira.request)
            .toHaveBeenCalledWith options, jasmine.any(Function)

        # Invalid URL 
        @jira.request.mostRecentCall.args[1] null, statusCode:404, null
        expect(@cb).toHaveBeenCalledWith 'Invalid URL'

        @jira.request.mostRecentCall.args[1] null, statusCode:401, null
        expect(@cb).toHaveBeenCalledWith(
            '401: Unable to connect to JIRA during rapidView search.')

        # Successful Request
        @jira.request.mostRecentCall.args[1] null,
            statusCode:200,
            body:
                views: [name: 'ABC']

        expect(@cb).toHaveBeenCalledWith null, name: 'ABC'

    it "Gets the last sprint for a Rapid View", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl("sprints/1", true)
            method: 'GET'
            json: true

        @jira.getLastSprintForRapidView 1, @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        # Invalid URL 
        @jira.request.mostRecentCall.args[1] null, statusCode:404, null
        expect(@cb).toHaveBeenCalledWith 'Invalid URL'

        @jira.request.mostRecentCall.args[1] null, statusCode:401, null
        expect(@cb).toHaveBeenCalledWith(
            '401: Unable to connect to JIRA during sprints search.')

        # Successful Request
        @jira.request.mostRecentCall.args[1] null,
            statusCode:200,
            body:
                sprints: [name: 'ABC']

        expect(@cb).toHaveBeenCalledWith null, name: 'ABC'
        
    it "Adds an issue to a sprint", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl("sprint/1/issues/add", true)
            method: 'PUT'
            json: true
            followAllRedirects: true
            body:
                issueKeys: [2]

        @jira.addIssueToSprint 2, 1, @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        # Invalid URL 
        @jira.request.mostRecentCall.args[1] null, statusCode:404, null
        expect(@cb).toHaveBeenCalledWith 'Invalid URL'

        @jira.request.mostRecentCall.args[1] null, statusCode:401, null
        expect(@cb).toHaveBeenCalledWith(
            '401: Unable to connect to JIRA to add to sprint.')

    it "Creates a Link Between two Issues", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "issueLink"
            method: 'POST'
            json: true
            body: 'test'
            followAllRedirects: true

        @jira.issueLink 'test', @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        # Invalid Project
        @jira.request.mostRecentCall.args[1] null, statusCode:404, null
        expect(@cb).toHaveBeenCalledWith 'Invalid project.'

        @jira.request.mostRecentCall.args[1] null, statusCode:401, null
        expect(@cb).toHaveBeenCalledWith(
            '401: Unable to connect to JIRA during issueLink.')

        # Successful Request
        @jira.request.mostRecentCall.args[1] null, statusCode:200
        expect(@cb).toHaveBeenCalledWith null

    it "Gets versions for a project", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "project/ABC/versions"
            method: 'GET'

        @jira.getVersions 'ABC', @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        # Invalid Project
        @jira.request.mostRecentCall.args[1] null, statusCode:404, null
        expect(@cb).toHaveBeenCalledWith 'Invalid project.'

        @jira.request.mostRecentCall.args[1] null, statusCode:401, null
        expect(@cb).toHaveBeenCalledWith(
            '401: Unable to connect to JIRA during getVersions.')

        # Successful Request
        @jira.request.mostRecentCall.args[1] null,
            statusCode:200, '{"body":"none"}'
        expect(@cb).toHaveBeenCalledWith null, body:'none'

    it "Creates a version for a project", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "version"
            method: 'POST'
            json: true
            body: 'ABC'
            followAllRedirects: true

        @jira.createVersion 'ABC', @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        # Invalid Project
        @jira.request.mostRecentCall.args[1] null, statusCode:404, null
        expect(@cb).toHaveBeenCalledWith 'Version does not exist or the
 currently authenticated user does not have permission to view it'

        @jira.request.mostRecentCall.args[1] null, statusCode:403, null
        expect(@cb).toHaveBeenCalledWith(
            'The currently authenticated user does not have
 permission to edit the version')

        @jira.request.mostRecentCall.args[1] null, statusCode:401, null
        expect(@cb).toHaveBeenCalledWith(
            '401: Unable to connect to JIRA during createVersion.')

        # Successful Request
        @jira.request.mostRecentCall.args[1] null,
            statusCode:201, '{"body":"none"}'
        expect(@cb).toHaveBeenCalledWith null, '{"body":"none"}'

    it "Passes a search query to Jira, default options", ->
        fields = ["summary", "status", "assignee", "description"]
        options =
            rejectUnauthorized: true
            uri: makeUrl "search"
            method: 'POST'
            json: true
            followAllRedirects: true
            body:
                jql: 'aJQLstring'
                startAt: 0
                maxResults: 50
                fields: fields

        @jira.searchJira 'aJQLstring', {}, @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        # Invalid Project
        @jira.request.mostRecentCall.args[1] null, statusCode:400, null
        expect(@cb).toHaveBeenCalledWith 'Problem with the JQL query'

        @jira.request.mostRecentCall.args[1] null, statusCode:401, null
        expect(@cb).toHaveBeenCalledWith(
            '401: Unable to connect to JIRA during search.')

        # Successful Request
        @jira.request.mostRecentCall.args[1] null,
            statusCode:200, '{"body":"none"}'
        expect(@cb).toHaveBeenCalledWith null, '{"body":"none"}'

    it "Passes a search query to Jira, non-default options", ->
        fields = ["assignee", "description", "test"]
        options =
            rejectUnauthorized: true
            uri: makeUrl "search"
            method: 'POST'
            json: true
            followAllRedirects: true
            body:
                jql: 'aJQLstring'
                startAt: 200
                maxResults: 100
                fields: fields

        @jira.searchJira 'aJQLstring', { maxResults: 100, fields: fields, startAt: 200 }, @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

    it "Gets a specified User's OPEN Issues", ->
        spyOn @jira, 'searchJira'
        expected = "assignee = test AND status in (Open, \"In Progress\",
 Reopened)"
        
        @jira.getUsersIssues 'test', true, @cb
        expect(@jira.searchJira).toHaveBeenCalledWith expected, {},
            jasmine.any(Function)

    it "Gets the sprint issues and information", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl("rapid/charts/sprintreport?rapidViewId=1&sprintId=1", true)
            method: 'GET'
            json: true

        @jira.getSprintIssues 1, 1, @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        @jira.request.mostRecentCall.args[1] null, statusCode:404, null
        expect(@cb).toHaveBeenCalledWith 'Invalid URL'

     it "Gets ALL a specified User's Issues", ->
        spyOn @jira, 'searchJira'
        expected = "assignee = test"
        
        @jira.getUsersIssues 'test', false, @cb
        expect(@jira.searchJira).toHaveBeenCalledWith expected, {},
            jasmine.any(Function)

    it "Deletes an Issue", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "issue/1"
            method: 'DELETE'
            json: true
            followAllRedirects: true

        @jira.deleteIssue 1, @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        @jira.request.mostRecentCall.args[1] null, statusCode:401, null
        expect(@cb).toHaveBeenCalledWith '401: Error while deleting'

        # Successful Request
        @jira.request.mostRecentCall.args[1] null, statusCode:204
        expect(@cb).toHaveBeenCalledWith null, 'Success'

    it "Updates an Issue", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "issue/1"
            body: 'updateGoesHere'
            method: 'PUT'
            json: true
            followAllRedirects: true

        @jira.updateIssue 1, 'updateGoesHere', @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        @jira.request.mostRecentCall.args[1] null, statusCode:401
        expect(@cb).toHaveBeenCalledWith '401: Error while updating'

        # Successful Request
        @jira.request.mostRecentCall.args[1] null, statusCode:200
        expect(@cb).toHaveBeenCalledWith null, 'Success'

    it "Assigns an Issue", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "issue/1/assignee"
            json: {name: 'newAssignee'}
            method: 'PUT'
            followAllRedirects: true

        @jira.assign 1, 'newAssignee', @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        @jira.request.mostRecentCall.args[1] null, statusCode:400
        expect(@cb).toHaveBeenCalledWith '400: Error while assigning'

        # Successful Request
        @jira.request.mostRecentCall.args[1] null, statusCode:204
        expect(@cb).toHaveBeenCalledWith null, 'Success'

    it "Lists Transitions", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "issue/1/transitions"
            method: 'GET'
            json: true

        @jira.listTransitions 1, @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        @jira.request.mostRecentCall.args[1] null, statusCode:404, null
        expect(@cb).toHaveBeenCalledWith 'Issue not found'

        @jira.request.mostRecentCall.args[1] null, statusCode:401
        expect(@cb).toHaveBeenCalledWith '401: Error while updating'

        # Successful Request
        @jira.request.mostRecentCall.args[1] null, statusCode:200,
            transitions:"someTransitions"
        expect(@cb).toHaveBeenCalledWith null, "someTransitions"

    it "Transitions an issue", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "issue/1/transitions"
            body: 'someTransition'
            method: 'POST'
            followAllRedirects: true
            json: true

        @jira.transitionIssue 1, 'someTransition', @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        @jira.request.mostRecentCall.args[1] null, statusCode:401
        expect(@cb).toHaveBeenCalledWith '401: Error while updating'

        # Successful Request
        @jira.request.mostRecentCall.args[1] null, statusCode:204
        expect(@cb).toHaveBeenCalledWith null, "Success"

    it "Lists Projects", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "project"
            method: 'GET'
            json: true

        @jira.listProjects @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        @jira.request.mostRecentCall.args[1] null, statusCode:401
        expect(@cb).toHaveBeenCalledWith '401: Error while updating'

        @jira.request.mostRecentCall.args[1] null, statusCode:500
        expect(@cb).toHaveBeenCalledWith '500: Error while retrieving list.'

        # Successful Request
        @jira.request.mostRecentCall.args[1] null, statusCode:200, "body"
        expect(@cb).toHaveBeenCalledWith null, "body"

    it "Adds a comment to an issue", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "issue/1/comment"
            body: {
                'body': 'aComment'
            }
            method: 'POST'
            followAllRedirects: true
            json: true

        @jira.addComment 1, 'aComment', @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        @jira.request.mostRecentCall.args[1] null, statusCode:400,
            '{"body:"none"}'
        expect(@cb).toHaveBeenCalledWith 'Invalid Fields: "{\\"body:\\"none\\"}"'

        # Successful Request
        @jira.request.mostRecentCall.args[1] null, statusCode:201
        expect(@cb).toHaveBeenCalledWith null, "Success"

    it "Adds a worklog to a project", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "issue/1/worklog"
            body: 'aWorklog'
            method: 'POST'
            followAllRedirects: true
            json: true

        @jira.addWorklog 1, 'aWorklog', @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        @jira.request.mostRecentCall.args[1] null, statusCode:400,
            '{"body:"none"}'
        expect(@cb).toHaveBeenCalledWith 'Invalid Fields: "{\\"body:\\"none\\"}"'

        @jira.request.mostRecentCall.args[1] null, statusCode:403
        expect(@cb).toHaveBeenCalledWith 'Insufficient Permissions'

        @jira.request.mostRecentCall.args[1] null, statusCode:401
        expect(@cb).toHaveBeenCalledWith '401: Error while updating'

        # Successful Request
        @jira.request.mostRecentCall.args[1] null, statusCode:201
        expect(@cb).toHaveBeenCalledWith null, "Success"

    it "Lists Issue Types", ->
        options =
            rejectUnauthorized: true
            uri: makeUrl "issuetype"
            method: 'GET'
            json: true

        @jira.listIssueTypes @cb
        expect(@jira.request).toHaveBeenCalledWith options, jasmine.any(Function)

        @jira.request.mostRecentCall.args[1] null, statusCode:401
        expect(@cb).toHaveBeenCalledWith '401: Error while retrieving issue types'

        # Successful Request
        @jira.request.mostRecentCall.args[1] null, statusCode:200, "body"
        expect(@cb).toHaveBeenCalledWith null, "body"
