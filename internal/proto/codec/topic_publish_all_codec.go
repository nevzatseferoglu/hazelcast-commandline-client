/*
* Copyright (c) 2008-2023, Hazelcast, Inc. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License")
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

package codec

import (    
    iserialization "github.com/hazelcast/hazelcast-go-client"
    proto "github.com/hazelcast/hazelcast-go-client"
)


const(
    TopicPublishAllCodecRequestMessageType  = int32(0x040400)
    TopicPublishAllCodecResponseMessageType = int32(0x040401)

    TopicPublishAllCodecRequestInitialFrameSize = proto.PartitionIDOffset + proto.IntSizeInBytes

)

// Publishes all messages to all subscribers of this topic

func EncodeTopicPublishAllRequest(name string, messages []iserialization.Data) *proto.ClientMessage {
    clientMessage := proto.NewClientMessageForEncode()
    clientMessage.SetRetryable(false)

    initialFrame := proto.NewFrameWith(make([]byte, TopicPublishAllCodecRequestInitialFrameSize), proto.UnfragmentedMessage)
    clientMessage.AddFrame(initialFrame)
    clientMessage.SetMessageType(TopicPublishAllCodecRequestMessageType)
    clientMessage.SetPartitionId(-1)

    EncodeString(clientMessage, name)
    EncodeListMultiFrameForData(clientMessage, messages)

    return clientMessage
}

