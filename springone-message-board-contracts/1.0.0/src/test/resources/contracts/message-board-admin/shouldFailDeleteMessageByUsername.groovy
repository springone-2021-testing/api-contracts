import org.springframework.cloud.contract.spec.Contract

Contract.make {
    description("should fail delete the message by username")
    request {
        url("/message/anamethat_doesnotexist")
        method(DELETE())
        headers {
            contentType(applicationJson())
        }
    }
    response {
        status(OK())
        body([message: "Failure", type: "Delete", parameter: "-1"])
        headers {
            contentType(applicationJson())
        }

    }
}
