import org.springframework.cloud.contract.spec.Contract

Contract.make {
    description("should delete the message by username")
    request {
        url("/message?username=Cora")
        method(DELETE())
        headers {
            contentType(applicationJson())
        }
    }
    response {
        status(OK())
        body([message: "Success", type: "Delete", parameter: "1"])
        headers {
            contentType(applicationJson())
        }

    }
}