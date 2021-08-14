import org.springframework.cloud.contract.spec.Contract

Contract.make {
    description("should delete the message by name")
    request {
        url("/message/Cora")
        method(DELETE())
    }
    response {
        status(OK())
        body([message: "Success", type: "Delete"])
        headers {
            contentType(applicationJson())
        }

    }
}
