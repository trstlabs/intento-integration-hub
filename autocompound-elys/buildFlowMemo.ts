type SdkCoin = {
  denom: string;
  amount: string;
};

type FeedbackLoop = {
  response_index: number;
  response_key: string;
  msgs_index: number;
  msg_key: string;
  value_type: string;
};

type Comparison = {
  response_index: number;
  response_key: string;
  operand: string;
  operator: number;
  value_type: string;
};

type FlowConditions = {
  feedback_loops: FeedbackLoop[];
  comparisons: Comparison[];
};

type BaseFlowParams = {
  label: string;
  duration: string;
  start_at?: string;
  owner: string;
  fallback?: boolean;
  msgs: any[]; // raw Elys messages (non-authz-wrapped)
  conditions?: FlowConditions;
};

type HostedFlowParams = BaseFlowParams & {
  mode: "hosted";
  trustless_agent: string;
  fee_limit?: SdkCoin[];
};

type SelfHostedFlowParams = BaseFlowParams & {
  mode: "self";
  cid: string; //connection id on intento
  host_cid: string; //connection id on host (elys)
};

type FlowParams = HostedFlowParams | SelfHostedFlowParams;

export function buildFlowMemo(params: FlowParams): string {
  const {
    label,
    duration,
    owner,
    fallback = true,
    msgs,
    start_at = "0",
    conditions,
  } = params;

  // Wrap each message in a MsgExec block
  const msgExec = (msg: any): any => ({
    "@type": "/cosmos.authz.v1beta1.MsgExec",
    grantee: params.mode === "hosted" ? params.trustless_agent : owner,
    msgs: [msg],
  });

  const memo: any = {
    flow: {
      msgs: msgs.map(msgExec),
      label,
      duration,
      owner,
      start_at,
      fallback,
    },
  };

  // Append hosted or self-hosted mode specifics
  if (params.mode === "hosted") {
    memo.flow.trustless_agent = params.trustless_agent;
    if (params.fee_limit) {
      memo.flow.fee_limit = params.fee_limit;
    }
  } else {
    memo.flow.cid = params.cid;
    memo.flow.host_cid = params.host_cid;
  }

  // Add conditions if provided
  if (conditions) {
    memo.conditions = conditions;
  }

  return JSON.stringify(memo);
}
