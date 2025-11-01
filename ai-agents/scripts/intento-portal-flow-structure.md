```ts


export class FlowInput {
  label?: string
  msgs: string[]
  duration: number
  interval?: number
  startTime?: number
  feeFunds?: Coin
  configuration?: ExecutionConfiguration
  conditions?: ExecutionConditions
  trustlessAgent?: TrustlessAgentConfig
  icaAddressForAuthZ?: string
  connectionId?: string
  hostConnectionId?: string
  email?: string
  alertType?: string
  chainId?: string
}


export interface ExecutionConfiguration {
    /** if true, the flow response outputs are saved and can be used in logic */
    saveResponses: boolean;
    /** if true, the flow is not updatable */
    updatingDisabled: boolean;
    /**
     * If true, will execute until we get a successful flow execution, if false/unset will
     * always execute
     */
    stopOnSuccess: boolean;
    /**
     * If true, will execute until flow execution is successful, if false/unset will always
     * execute
     */
    stopOnFailure: boolean;
    /** If true, will stop if flow execution on the host chain times out */
    stopOnTimeout: boolean;
    /** If true, will use the owner account balance when flow account funds run out */
    walletFallback: boolean;
}


/** ExecutionConditions provides execution conditions for the flow */
export interface ExecutionConditions {
    /**
     * Replace value with value from message or response from another flow’s
     * latest output
     */
    feedbackLoops: FeedbackLoop[];
    /** Comparison with response response value */
    comparisons: Comparison[];
    /**
     * optional array of dependent intents that when executing succesfully, stops
     * execution
     */
    stopOnSuccessOf: bigint[];
    /**
     * optional array of dependent intents that when not executing succesfully,
     * stops execution
     */
    stopOnFailureOf: bigint[];
    /**
     * optional array of dependent intents that should be executed succesfully
     * after their latest call before execution is allowed
     */
    skipOnFailureOf: bigint[];
    /**
     * optional array of dependent intents that should fail after their latest
     * call before execution is allowed
     */
    skipOnSuccessOf: bigint[];
    /** True: Use AND for combining comparisons. False: Use OR for combining comparisons. */
    useAndForComparisons: boolean;
}



/** config for a trustless agent for flow execution on host chain */
export interface TrustlessAgentConfig {
    agentAddress: string;
    /** optional, if set to empty array, no fee limit is set and no fees are charged */
    feeLimit: Coin[];
    /** optional for display */
    connectionId: string;
}


/**
 * Replace value with value from message or response from another flow’s
 * latest output before execution
 */
export interface FeedbackLoop {
    /** flow to get the latest response value from, optional */
    flowId: bigint;
    /** index of the responses */
    responseIndex: number;
    /** for example "Amount" */
    responseKey: string;
    /** index of the msg to replace */
    msgsIndex: number;
    /** key of the message to replace (e.g. Amount[0].Amount, FromAddress) */
    msgKey: string;
    /** can be anything from math.Int, sdk.Coin, sdk.Coins, string, []string, []math.Int, math.Dec */
    valueType: string;
    /** True: calculate the difference with the previous value instead of using the value directly. */
    differenceMode: boolean;
    /** config of ICQ to perform */
    icqConfig?: ICQConfig;
}


/**
 * Comparison is checked on the response in JSON before execution of
 * flow and outputs true or false
 */
export interface Comparison {
    /** get the latest response value from other flow, optional */
    flowId: bigint;
    /** index of the message response, optional */
    responseIndex: number;
    /** e.g. Amount[0].Amount, FromAddress, optional */
    responseKey: string;
    /** can be anything from math.Int, sdk.Coin, sdk.Coins, string, []string, []math.Int,  math.Dec */
    valueType: string;
    operator: ComparisonOperator;
    operand: string;
    /** True: Calculate the difference with the previous value. */
    differenceMode: boolean;
    /** config of ICQ to perform */
    icqConfig?: ICQConfig;
}


/** config for using interchain queries */
export interface ICQConfig {
    connectionId: string;
    chainId: string;
    timeoutPolicy: TimeoutPolicy;
    timeoutDuration: Duration;
    /** e.g. store/bank/key store/staking/key */
    queryType: string;
    /** key in the store that stores the query e.g. stakingtypes.GetValidatorKey(validatorAddressBz) */
    queryKey: string;
    /** should be reset after execution */
    response: Uint8Array;
}

export declare enum TimeoutPolicy {
    REJECT_QUERY_RESPONSE = 0,
    RETRY_QUERY_REQUEST = 1,
    EXECUTE_QUERY_CALLBACK = 2,
    UNRECOGNIZED = -1
}

/** Comparison operators that can be used for various types. */
export declare enum ComparisonOperator {
    /** EQUAL - Equality check (for all types) */
    EQUAL = 0,
    /** CONTAINS - Contains check (for strings, arrays, etc.) */
    CONTAINS = 1,
    /** NOT_CONTAINS - Not contains check (for strings, arrays, etc.) */
    NOT_CONTAINS = 2,
    /** SMALLER_THAN - Less than check (for numeric types) */
    SMALLER_THAN = 3,
    /** LARGER_THAN - Greater than check (for numeric types) */
    LARGER_THAN = 4,
    /** GREATER_EQUAL - Greater than or equal to check (for numeric types) */
    GREATER_EQUAL = 5,
    /** LESS_EQUAL - Less than or equal to check (for numeric types) */
    LESS_EQUAL = 6,
    /** STARTS_WITH - Starts with check (for strings) */
    STARTS_WITH = 7,
    /** ENDS_WITH - Ends with check (for strings) */
    ENDS_WITH = 8,
    /** NOT_EQUAL - Not equal check (for all types) */
    NOT_EQUAL = 9,
    UNRECOGNIZED = -1
}


export interface Duration {
    /**
     * Signed seconds of the span of time. Must be from -315,576,000,000
     * to +315,576,000,000 inclusive. Note: these bounds are computed from:
     * 60 sec/min * 60 min/hr * 24 hr/day * 365.25 days/year * 10000 years
     */
    seconds: bigint;
    /**
     * Signed fractions of a second at nanosecond resolution of the span
     * of time. Durations less than one second are represented with a 0
     * `seconds` field and a positive or negative `nanos` field. For durations
     * of one second or more, a non-zero value for the `nanos` field must be
     * of the same sign as the `seconds` field. Must be from -999,999,999
     * to +999,999,999 inclusive.
     */
    nanos: number;
}
```