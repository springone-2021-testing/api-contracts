import org.springframework.cloud.contract.spec.Contract

Contract.make {
    description("should delete the message by keyword")
    request {
        url("/message?keyword=selling")
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
