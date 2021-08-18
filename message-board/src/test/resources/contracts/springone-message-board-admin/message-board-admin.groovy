import org.springframework.cloud.contract.spec.Contract

Contract.make {
    description("should delete the message by name")
    request {
        url("/message/Cora")
        method(DELETE())
        headers {
            header 'Content-Type': 'application/json;charset=UTF-8'
        }
    }
    response {
        status(OK())
        body([message: "Success", type: "Delete", parameter: "1"])
        headers {
            header 'Content-Type': 'application/json;charset=UTF-8'
        }

    }
}
