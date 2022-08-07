//
//  DataIntegrationTests.swift
//  DataIntegrationTests
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/08/22.
//

import XCTest
import Data
import Domain
import Infra

class RemoteAddAccountIntegrationTests: XCTestCase {

    func testRemoteAddAccountWorkdsCorrectly() {
        let exp = expectation(description: "wait for request completion")

        let url = URL(string: "https://fordevs.herokuapp.com/api/signup")!
        let httpPostClient = AlamofireAdapter()
        let remoteAddAccount = RemoteAddAccount(url: url, httpClient: httpPostClient)

        let addAccountModel = AddAccountModel(name: "name_test", email: "name_new@teste.com", password: "12341234", passwordConfirmation: "12341234")
        remoteAddAccount.add(addAccountModel: addAccountModel) { result in
            switch (result) {
            case .success(let accountModel):
                XCTAssertEqual(accountModel.name, addAccountModel.name)
                XCTAssertEqual(accountModel.email, addAccountModel.email)
                XCTAssertNotNil(accountModel.token)
            case .failure(let error): XCTFail("Expected integration test to succeed, failed with \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10)
    }

}
